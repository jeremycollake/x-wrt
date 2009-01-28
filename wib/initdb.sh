#!/usr/bin/env bash
rm -f database/dev.db
mkdir -p database
sqlite3 database/dev.db <<EOF
BEGIN TRANSACTION;
CREATE TABLE schema_info (version integer);
INSERT INTO "schema_info" VALUES(17);
CREATE TABLE boards ("id" INTEGER PRIMARY KEY NOT NULL, "name" varchar(255), "arch" varchar(255), "kernel" varchar(255), "title" varchar(255), "description" text, "path" varchar(255));
CREATE TABLE filesystems ("id" INTEGER PRIMARY KEY NOT NULL, "name" varchar(255), "description" varchar(255), "overhead_size" integer, "compression_ratio" float);
INSERT INTO "filesystems" VALUES(1, 'squashfs', 'Highly compressed read-only root filesystem with an overlay filesystem. Changes will be written to a writable JFFS2 partition. (preferred filesystem type)', 315000, 0.5);
INSERT INTO "filesystems" VALUES(2, 'jffs2', 'JFFS2 root filesystem for flash. The complete root filesystem is writable.', 658280, 0.7);
INSERT INTO "filesystems" VALUES(3, 'ext2', 'EXT2 root filesystem.', 0, 1.0);
CREATE TABLE boards_filesystems ("board_id" integer, "filesystem_id" integer);
CREATE TABLE maintainers ("id" INTEGER PRIMARY KEY NOT NULL, "name" varchar(255), "email" varchar(255));
INSERT INTO "maintainers" VALUES(1, 'OpenWrt Developers Team', 'openwrt-devel@openwrt.org');
CREATE TABLE profiles ("id" INTEGER PRIMARY KEY NOT NULL, "board_id" INTEGER, "name" varchar(255), title varchar(255), description text);
CREATE TABLE categories ("id" INTEGER PRIMARY KEY NOT NULL, "name" varchar(255), "description" varchar(255));
CREATE TABLE dependencies ("dependant" integer, "depends_on" integer);
CREATE TABLE packages ("id" INTEGER PRIMARY KEY NOT NULL, "name" varchar(255), "title" varchar(255), "description" text, "size" integer, "category_id" integer, "maintainer_id" integer, "version" varchar(255), "status" varchar(255));
CREATE TABLE preconfigs ("id" INTEGER PRIMARY KEY NOT NULL, package_id INTEGER, configstr varchar(255), label text, datatype varchar(255), defaultstr text);
CREATE TABLE boards_packages("board_id" INTEGER, "package_id" INTEGER);
CREATE TABLE profiles_packages ("profile_id" integer, "package_id" integer);
COMMIT;
EOF
