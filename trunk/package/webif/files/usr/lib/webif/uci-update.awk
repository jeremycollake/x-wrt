# Configuration update functions
#
# Copyright (C) 2006 by Fokus Fraunhofer <carsten.tittel@fokus.fraunhofer.de>
# Copyright (C) 2006 by Felix Fietkau <nbd@openwrt.org>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA


function read_file(filename,  result) {
	while ((getline <filename) == 1) {
		result = result $0 "\n"
	}
	gsub(/\n*$/, "", result)
	return result
}

function cmd2option(str,  tmp) {
	if (match(str,"=")!=0) {
		res = "\toption " substr(str,1,RSTART-1) "\t'" substr(str,RSTART+1) "'"
	} else {
		res= ""
	}
	return res
}

function cmd2config(atype,  aname) {
	return "config \"" atype "\" \"" aname "\""
}

function update_config(cfg, update,  \
  lines, line, l, n, i, i2, cmds, section, scnt, remove, tmp, aidx, rest) {
	scnt = 1
	linecnt=split(cfg "\n", lines, "\n")
	cmdcount=split(update ";", cmds, ";")
	for (i = 1; i < cmdcount; i++) {
		gsub(/^[ \t]*/, "", cmds[i])
		gsub(/[ \t]*$/, "", cmds[i])
	}

	cfg = ""
	for (n = 1; n < linecnt; n++) {
		# stupid parser for quoted arguments (e.g. for the type string).
		# not to be used to gather variable values (backslash escaping doesn't work)
		line = lines[n]
		gsub(/^[ \t]*/, "", line)
		gsub(/#.*$/, "", line)
		i2 = 1
		delete l
		rest = line
        	while (length(rest)) {
			if (match(rest, /[ \t\"]+/)) {
				if (RSTART>1) {
					l[i2] = substr(rest,1,RSTART-1)
					i2++
				}
				aidx=index(rest,"\"")
				if (aidx>=RSTART && aidx<=RSTART+RLENGTH) {
					rest=substr(rest,aidx+1)
					# find the end of the string
					match(rest,/\"/)
					l[i2]=substr(rest,1,RSTART-1)
					i2++
				}
				rest=substr(rest,RSTART+RLENGTH)
			} else {
				l[i2] = rest
				i2++
				rest = ""
			}
		}
		line = lines[n]
		
		# when a command wants to set a config value for the current
		# section and a blank line is encountered before an option with
		# the same name, insert it here to maintain some coherency between
		# manually and automatically created option lines
		# if an option with the same name appears after this point, simply
		# ignore it, because it is already set.
		if ((section != "") && (l[1] != "option")) {
			if (line ~ /^[ \t]*$/) {
				for (i = 1; i < cmdcount; i++) {
					if (cmds[i] ~ "^" section "\\.") {
						gsub("^" section ".", "", cmds[i])
						cfg = cfg cmd2option(cmds[i]) "\n"
						gsub(/=.*$/, "", cmds[i])
						cmds[i] = "-" section "." cmds[i]
					}
				}
			}
		}

		if (l[1] == "config") {
			# look for all unset values
			if (section != "") {
				flag=0
				for (i = 1; i < cmdcount; i++) {
					if (cmds[i] ~ "^" section "\\.") {
						flag=1
						gsub("^" section ".", "", cmds[i])
						cfg = cfg cmd2option(cmds[i]) "\n"
						
						cmds[i] = "-" section "." cmds[i]
					} 
				}
				if (flag!=0) cfg = cfg "\n"
			}
			
			remove = ""
			section = l[3]
			if (!length(section)) {
				section = "cfg" scnt
			}	
			scnt++
			for (i = 1; i < cmdcount; i++) {
				if (cmds[i] == "-" section) {
					remove = "section"
					cmds[i] = ""
				} else if (cmds[i] ~ "^@" section "=") {
					cmds[i] = ""
				} else if (cmds[i] ~ "^\\*" section "=") {
					gsub("^\\*" section "=", "", cmds[i])
					line = cmd2config(l[2],cmds[i]) 
					cmds[i] = ""
				}
			}
		}
		if (remove == "option") remove = ""
		if (l[1] == "option") {
			for (i = 1; i < cmdcount; i++) {
				if (cmds[i] ~ "^-" section "\\." l[2] "$") remove = "option"
				# if a supplied config value already exists, replace the whole line
				if (match(cmds[i], "^" section "." l[2] "=")) {
					gsub("^" section ".", "", cmds[i])
					line = cmd2option(cmds[i]) 
					cmds[i] = ""
				}
			}
		}
		if (remove == "") cfg = cfg line "\n"
	}
	
	# any new options for the last section??
	if (section != "") {
		for (i = 1; i < cmdcount; i++) {
			if (cmds[i] ~ "^" section "\\.") {
				gsub("^" section ".", "", cmds[i])
				cfg = cfg cmd2option(cmds[i]) "\n"
				
				cmds[i] = "-" section "." cmds[i]
			} 
		}
	}

	# TODO: generate a new section if any foo.bar=baz command remains
	for (i=1; i<cmdcount; i++) {
		if (cmds[i] ~ "^@") {
			# new section
			section = stype = substr(cmds[i],2)
			gsub(/=.*$/,"",section)
			gsub(/^.*=/,"",stype)
			cfg = cfg "\nconfig \"" stype "\" \"" section "\"\n"
			for (i2=1; i2<cmdcount; i2++) {
				if (cmds[i2] ~ "^" section "\\.") {
					gsub("^" section ".", "", cmds[i2])
					cfg = cfg cmd2option(cmds[i2]) "\n"
					cmds[i2] = "-" section "." cmds[i2]
				}
			}
			cfg = cfg "\n"
		}
	}

	return cfg
}
