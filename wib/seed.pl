#!/usr/bin/perl
#
# Metadata converter for the Web Image Builder
# Copyright (C) 2007 by Felix Fietkau <nbd@openwrt.org>
#

use DBI;
use strict;
use warnings;

my %preconfig;
my %srcpackage;
my %package;
my %category;
my %section;
my %fs;

sub get_multiline {
	my $prefix = shift;
	my $first = shift;
	my $line;
	my $res;

	while ($line = $first or $line = <>) {
		undef $first;
		next unless $line;
		chomp $line;
		return $res if $line =~ /^@@/;
		$prefix and $line =~ s/^\s*/$prefix/g;
		if (($res and $res =~ /\w+/s) or ($line and $line =~ /\w+/)) {
			$res .= $line;
			$line =~ /\w+/ or $res .= "<br />";
		}
	}
	return $res;
}

sub parse_target_metadata() {
	my ($target, @target, $profile);
	while (<>) {
		chomp;
		/^Target:\s*((.+)-(\d+\.\d+))\s*$/ and do {
			my $conf = uc $3.'_'.$2;
			$conf =~ tr/\.-/__/;
			$target = {
				id => $1,
				conf => $conf,
				board => $2,
				kernel => $3,
				profiles => []
			};
			push @target, $target;
		};
		/^Target-Name:\s*(.+)\s*$/ and $target->{name} = $1;
		/^Target-Path:\s*(.+)\s*$/ and $target->{path} = $1;
		/^Target-Arch:\s*(.+)\s*$/ and $target->{arch} = $1;
		/^Target-Features:\s*(.+)\s*$/ and $target->{features} = [ split(/\s+/, $1) ];
		/^Target-Description:/ and $target->{desc} = get_multiline();
		/^Linux-Version:\s*(.+)\s*$/ and $target->{version} = $1;
		/^Linux-Release:\s*(.+)\s*$/ and $target->{release} = $1;
		/^Linux-Kernel-Arch:\s*(.+)\s*$/ and $target->{karch} = $1;
		/^Default-Packages:\s*(.+)\s*$/ and $target->{packages} = [ split(/\s+/, $1) ];
		/^Target-Profile:\s*(.+)\s*$/ and do {
			$profile = {
				id => $1,
				name => $1,
				packages => []
			};
			push @{$target->{profiles}}, $profile;
		};
		/^Target-Profile-Name:\s*(.+)\s*$/ and $profile->{name} = $1;
		/^Target-Profile-Packages:\s*(.*)\s*$/ and $profile->{packages} = [ split(/\s+/, $1) ];
		/^Target-Profile-Description:\s*(.*)\s*/ and $profile->{desc} = get_multiline();
		/^Target-Profile-Config:/ and $profile->{config} = get_multiline("\t");
		/^Target-Profile-Kconfig:/ and $profile->{kconfig} = 1;
	}
	foreach my $target (@target) {
		@{$target->{profiles}} > 0 or $target->{profiles} = [
			{
				id => 'Default',
				name => 'Default',
				desc => 'Default package set',
				packages => []
			}
		];
	}
	return @target;
}

sub parse_package_metadata() {
	my $pkg;
	my $makefile;
	my $src;
	my $preconfig;
	while (<>) {
		chomp;
		/^Source-Makefile: \s*(.+\/([^\/]+)\/Makefile)\s*$/ and do {
			$makefile = $1;
			$src = $2;
			$srcpackage{$src} = [];
			undef $pkg;
		};
		/^Package: \s*(.+)\s*$/ and do {
			$pkg = {
				src => $src,
				makefile => $makefile,
				name => $1,
				default => "m if ALL",
				depends => [],
				builddepends => [],
				preconfig => [],
			};
			$package{$1} = $pkg;
			push @{$srcpackage{$src}}, $pkg;
		};
		/^Version: \s*(.+)\s*$/ and $pkg->{version} = $1;
		/^Title: \s*(.+)\s*$/ and $pkg->{title} = $1;
		/^Menu: \s*(.+)\s*$/ and $pkg->{menu} = $1;
		/^Submenu: \s*(.+)\s*$/ and $pkg->{submenu} = $1;
		/^Submenu-Depends: \s*(.+)\s*$/ and $pkg->{submenudep} = $1;
		/^Default: \s*(.+)\s*$/ and $pkg->{default} = $1;
		/^Provides: \s*(.+)\s*$/ and do {
			my @vpkg = split /\s+/, $1;
			foreach my $vpkg (@vpkg) {
				$package{$vpkg} or $package{$vpkg} = { vdepends => [] };
				push @{$package{$vpkg}->{vdepends}}, $pkg->{name};
			}
		};
		/^Depends: \s*(.+)\s*$/ and $pkg->{depends} = [ split /\s+/, $1 ];
		/^Section:\s*(.+)\s*$/ and $pkg->{section} = $1;
		/^Category: \s*(.+)\s*$/ and do {
			$pkg->{category} = $1;
			defined $category{$1} or $category{$1} = {};
			defined $category{$1}->{$src} or $category{$1}->{$src} = [];
			push @{$category{$1}->{$src}}, $pkg;
		};
		/^Description: \s*(.*)\s*$/ and $pkg->{description} = get_multiline("\t\t ", $1);
		/^Config: \s*(.*)\s*$/ and $pkg->{config} = get_multiline("", $1);
		/^Prereq-Check:/ and $pkg->{prereq} = 1;
		/^Preconfig:\s*(.+)\s*$/ and do {
			my $pkgname = $pkg->{name};
			$preconfig{$pkgname} = $pkg->{preconfig};
			$preconfig = {
				id => $1
			};
			push @{$pkg->{preconfig}}, $preconfig;
		};
		/^Preconfig-Type:\s*(.*?)\s*$/ and $preconfig->{type} = $1;
		/^Preconfig-Label:\s*(.*?)\s*$/ and $preconfig->{label} = $1;
		/^Preconfig-Default:\s*(.*?)\s*$/ and $preconfig->{default} = $1;
	}
	return %category;
}

# work around a sqlite-perl bug
sub dbh_do($$@) {
	my $dbh = shift;
	my $sql = shift;
	my @args = @_;
	my $sth = $dbh->prepare($sql);
	$sth->execute(@args) or print STDERR "ERROR IN DB QUERY: $sql - $!\n";
	$sth->finish;
	undef $sth;
}

sub fetch_filesystems($) {
	my $dbh = shift;
	my $sth = $dbh->prepare("SELECT id, name FROM filesystems");
	my ($id, $name);
	$sth->execute;
	while (($id, $name) = $sth->fetchrow_array) {
		$fs{$name} = $id;
	}
	undef $sth;
}

sub init_target($) {
	my $dir = shift;
	$dir or die "Syntax: $0 <image builder directory>\n";
	-d "$dir" or die 'Image builder directory not found';
	-f "$dir/.targetinfo" or die 'Cannot find target metadata';
	-f "$dir/.pkginfo" or die 'Cannot find package metadata';
	
	my $kernel;
	my $board;
	open CONFIG, "$dir/.config" or die 'Failed to open image builder config';
	while (<CONFIG>) {
		/^CONFIG_LINUX_2_(\d)_([A-Z0-9]+)=y/ and do {
			$kernel = "2.$1";
			$board = lc "$2";
		};
	}
	close CONFIG;
	$kernel or die 'Cannot find board/kernel version';
	
	$ARGV[0] = "$dir/.targetinfo";
	my @target = parse_target_metadata();
	my $target;
	foreach my $t (@target) {
		$t->{board} eq $board and $t->{kernel} eq $kernel and $target = $t;
	}
	$target or die 'Cannot find board/kernel in target metadata';
	
	return $target;
}

sub cleanup_target($$) {
	my $dbh = shift;
	my $target = shift;
	my $boardid;

	my $sth = $dbh->prepare("SELECT id FROM boards WHERE name=? and kernel=?");
	$sth->execute($target->{board}, $target->{kernel});
	
	while ($boardid = $sth->fetchrow_array) {
		my @profile;
		my $sth = $dbh->prepare("SELECT id FROM profiles WHERE board_id=?");
		$sth->execute($boardid);
		push @profile, $_ while ($_ = $sth->fetchrow_array);
		foreach my $profile (@profile) {
			dbh_do($dbh, "DELETE FROM profiles_packages WHERE profile_id=?", $profile);
			dbh_do($dbh, "DELETE FROM profiles WHERE id=?", $profile);
		}
		dbh_do($dbh, "DELETE FROM boards_filesystems WHERE board_id=?", $boardid);
		dbh_do($dbh, "DELETE FROM boards_packages WHERE board_id=?", $boardid);
		dbh_do($dbh, "DELETE FROM boards WHERE id=?", $boardid);
		undef $sth;
	}
}

sub next_id($$) {
	my $dbh = shift;
	my $table = shift;
	my $id;
	
	my $sth = $dbh->prepare("SELECT max(id) FROM $table");
	$sth->execute;
	$id = $sth->fetchrow_array or $id = 0;
	$id++;
	undef $sth;
	return $id;
}

sub add_board($$) {
	my $dbh = shift;
	my $target = shift;
	my $id = next_id($dbh, "boards");

	$target->{id} = $id;
	dbh_do($dbh, "INSERT INTO boards(id, name, arch, kernel, title, description, path) VALUES(?, ?, ?, ?, ?, ?, ?)", $id, $target->{board}, $target->{arch}, $target->{kernel}, $target->{name}, $target->{desc}, $target->{path});
	foreach my $f (@{$target->{features}}) {
		$fs{$f} and dbh_do($dbh, "INSERT INTO boards_filesystems VALUES(?, ?)", $id, $fs{$f});
	}
}

sub init_packages($) {
	my $dir = shift;
	my %pkgs;
	my $package;
	$ARGV[0] = "$dir/.pkginfo";
	parse_package_metadata;

	system("make -C $dir package_index");
	($? >> 8 == 0) or die 'Failed to make package index';
	
	open INDEX, "$dir/packages/Packages";
	while (<INDEX>) {
		chomp;
		s/^(Package:\s*base-files)-.+$/$1/;
		/^Package:\s*(.+)\s*$/ and do {
			$package = $package{$1};
			$pkgs{$1} = $package;
		};
		/^Version:\s*(.+)\s*$/ and $package->{version} = $1;
	}
	close INDEX;
	return %pkgs;
}

sub target_dep_valid($$) {
	my $target = shift;
	my $dep = shift;
	my $valid = 1;
	$dep =~ /^LINUX_2_(\d)/ and do {
		if ($target->{kernel} ne "2.$1") {
			$valid = 0;
		} elsif ($dep =~ /^LINUX_2_\d_([A-Z]+)/) {
			lc $target->{board} ne lc $1 and $valid = 0;
		}
	};
	return $valid;
}

sub add_package_preconfig($$) {
	my $dbh = shift;
	my $pkg = shift;
	my $cfg;
	
	@{$pkg->{preconfig}} > 0 or return;
	dbh_do($dbh, "DELETE FROM preconfigs WHERE package_id=?", $pkg->{id});
	while ($cfg = shift @{$pkg->{preconfig}}) {
		dbh_do($dbh, "INSERT INTO preconfigs(package_id, configstr, datatype, label, defaultstr) VALUES(?,?,?,?,?)", $pkg->{id}, $cfg->{id}, $cfg->{type}, $cfg->{label}, $cfg->{default});
	}
}

sub add_board_packages($$$) {
	my $dbh = shift;
	my $target = shift;
	my $packages = shift;
	my $board_id = $target->{id};
	my $id = next_id($dbh, "packages");
	my $cat_id = next_id($dbh, "categories");
	my $sth = $dbh->prepare("SELECT id, version FROM packages WHERE name=?");
	my $sth2 = $dbh->prepare("SELECT id FROM categories WHERE name=? LIMIT 1");
	
	# insert all packages and categories into the database
	foreach my $pkg (values %$packages) {
		my $valid = 1;
		next unless $pkg->{name};
		foreach my $dep (@{$pkg->{depends}}) {
			if ($dep =~ /^\@(LINUX.+)$/) {
				my @deps = split /||/, $dep;
				$valid = 0;
				foreach my $dep (@deps) {
					$valid ||= target_dep_valid($target, $dep);
				}
			}
		}
		next unless $valid;
		my ($pkgid, $version, $found);
		$sth->execute($pkg->{name});
		while (($pkgid, $version) = $sth->fetchrow_array) {
			if ($version eq $pkg->{version}) {
				$found = 1;
				$pkg->{id} = $pkgid;
			}
		}
		$found or do {
			my $section;
			$pkg->{id} = $id++;
			$section = $section{$pkg->{section}} or $section = {
				name => $pkg->{section}
			};
			$section->{id} or do {
				$sth2->execute($pkg->{section});
				my $id = $sth2->fetchrow_array();
				$id or do {
					$id = $cat_id;
					dbh_do($dbh, "INSERT INTO categories(id, name, description) VALUES(?, ?, NULL)", $cat_id++, $section->{name});
				};
				$section->{id} = $id;
			};
			dbh_do($dbh, "INSERT INTO packages(id, name, title, description, category_id, maintainer_id, version, status) VALUES(?, ?, ?, ?, ?, ?, ?, ?)", $pkg->{id}, $pkg->{name}, $pkg->{title}, $pkg->{desc}, $section->{id}, 1, $pkg->{version}, "active");
			add_package_preconfig($dbh, $pkg);
		};
		dbh_do($dbh, "INSERT INTO boards_packages VALUES(?, ?)", $board_id, $pkg->{id});
	}
	undef $sth;
	undef $sth2;
	
	# resolve dependencies
	$sth = $dbh->prepare("DELETE FROM dependencies WHERE dependant=?");
	$sth2 = $dbh->prepare("INSERT INTO dependencies VALUES(?, ?)");
	foreach my $pkg (values %$packages) {
		$sth->execute($pkg->{id});
		foreach my $dep (@{$pkg->{depends}}) {
			$dep =~ s/^\+//;
			my $id;
			$packages->{$dep} and $id = $packages->{$dep}->{id} and do {
				$sth2->execute($pkg->{id}, $id);
			}
		}
	}
	undef $sth;
	undef $sth2;
}

sub add_board_profiles($$) {
	my $dbh = shift;
	my $target = shift;
	my $id = next_id($dbh, "profiles");

	foreach my $profile (@{$target->{profiles}}) {
		next if $profile->{kconfig};
		my %pkgs;
		dbh_do($dbh, "INSERT INTO profiles(id, board_id, name, title, description) VALUES(?, ?, ?, ?, ?)", $id, $target->{id}, $profile->{id}, $profile->{name}, $profile->{desc});
		foreach my $p (@{$target->{packages}}, @{$profile->{packages}}) {
			$pkgs{$p} = 1;
		}
		foreach my $p (keys %pkgs) {
			next if ($p =~ /^-/ or $pkgs{"-$p"});
			my $pkg = $package{$p};
			next unless $pkg and $pkg->{id};
			dbh_do($dbh, "INSERT INTO profiles_packages VALUES(?, ?)", $id, $pkg->{id});
		}
		$id++;
	}
}

-d "./database" or die "Database directory not found.\n";
-f "./database/dev.db" or die "Cannot find database, please run initdb.sh first.\n";
my $dbh = DBI->connect("dbi:SQLite:dbname=./database/dev.db") or die 'Cannot connect to database';
my $dir = shift @ARGV;
$dir or die "Syntax: $0 <path_to_imagebuilder>\n";
fetch_filesystems($dbh);
my %board_pkgs = init_packages($dir);
my $target = init_target($dir);
$target->{path} = $dir;
cleanup_target($dbh, $target);
my $board_id = add_board($dbh, $target);
add_board_packages($dbh, $target, \%board_pkgs);
add_board_profiles($dbh, $target);
