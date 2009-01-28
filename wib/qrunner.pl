#!/usr/bin/perl
use POSIX qw(setsid);
use Fcntl qw(:flock);
use strict;
my @queue;

my $debug = 0;
my $active = 0;

sub spawn($) {
	my $cmd = shift;
	my $pid = fork();
	if (!$pid) {
		my $q;
		open QFILE, "<$cmd";
		$q .= $_ while (<QFILE>);
		close QFILE;
		chomp $q;
		$debug and print STDERR "Running $q\n";
		exec($q);
		exit(0);
	}
}

sub spawn_next() {
	if (@queue > 0) {
		spawn($queue[0]);
	} else {
		$active = 0;
	}
}

sub child_done() {
	wait;
	$debug and print STDERR "$queue[0] done!\n";
	unlink($queue[0]);
	shift @queue;
	spawn_next();
	$SIG{CHLD} = \&child_done;
}

sub find_qitem() {
	my @q = sort glob(".qrunner/q-*");
	my $qfile;
	my $q;

	@queue > 0 and return;

	while ((@q > 0) and !$q) {
		my $qfile = shift @q;
		open QFILE, "<$qfile";
		flock QFILE, LOCK_EX|LOCK_NB or do {
			$debug and print STDERR "Locking failed!\n";
			close QFILE;
			next;
		};
		$q .= $_ while (<QFILE>);
		flock QFILE, LOCK_UN;
		close QFILE;
		$q or do {
			$debug and print STDERR "Nothing to be done for $qfile\n";
			next;
		};
		$debug and print STDERR "Adding job: $q\n";
		push @queue, $qfile;
	};

	if (!$active and (@queue > 0)) {
		$active = 1;
		spawn($queue[0]);
	}
}

sub launch_runner() {
	$SIG{CHLD} = \&child_done;
	while (-f ".qrunner/lock") {
		sleep 1;
		find_qitem;
	}
	$debug and print STDERR "Lock file disappeared. Quitting!\n";
	exit(0);
}

sub add_command($) {
	my $cmd = shift;
	my $ticket = time().$$;
	open QFILE, ">.qrunner/q-$ticket";
	flock QFILE, LOCK_EX;
	print QFILE "$cmd";
	flock QFILE, LOCK_UN;
	close QFILE;
	print "$ticket\n";
}

-d ".qrunner" or mkdir(".qrunner");
open LOCKFILE, "<.qrunner/lock" or do {
	open LOCKFILE, ">.qrunner/lock";
};
flock LOCKFILE, LOCK_EX|LOCK_NB and do {
	$debug and print STDERR "no existing process, starting a new one\n";
	my $pid = fork();
	if (!$pid) {
		setsid();
		$debug or do {
			open STDIN, "</dev/null";
			open STDOUT, ">>/dev/null";
			open STDERR, ">>/dev/null";
		};
		launch_runner();
	}
};
close LOCKFILE;

sub ticket_place($) {
	my $ticket = shift;
	-f ".qrunner/q-$ticket" or return 0;
	my @files = sort glob ".qrunner/q-*";
	my $found = 0;
	my $i = 0;
	while (!$found and (@files > 0)) {
		$i++;
		my $file = shift @files;
		$file eq ".qrunner/q-$ticket" and $found = $i;
	}

	return $found;
}

$SIG{CHLD} = 'IGNORE';
my $cmd = shift @ARGV;
for ($cmd) {
	/^add$/ and do {
		my $cmdstr;
		$cmdstr .= $_ while (<>);
		$debug and print "Running command: $cmdstr\n";
		add_command($cmdstr);
	};
	/^place$/ and do {
		my $ticket = shift @ARGV;
		print ticket_place($ticket)."\n";
	}
}
