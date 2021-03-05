# Copyright (c) 2020  Díaz  Urbaneja Victor Diego Alejandro  aka  (Sodomon)
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.


SQLITE3     = /usr/bin/sqlite3
DB          = ./db.db
SCHEMA_DB   = ./data/database/schema.sql
EXECUTABLE  = ./data/agenda

all: db

db:
	$(SQLITE3) $(DB) < $(SCHEMA_DB)

install: 
	install -m775 $(EXECUTABLE) /usr/bin/
	mkdir -p /usr/share/agenda
	cp -r src/lib/ /usr/share/agenda
	cp -r data/agenda.ui /usr/share/agenda/agenda.ui
	cp -r src/init.lua /usr/share/agenda
	install -m644 $(DB) /usr/share/agenda
	install -m644 data/agenda.desktop /usr/share/applications
   
uninstall:
	rm -r /usr/share/agenda/
	rm -f /usr/share/applications/agenda.desktop
	rm -f /usr/bin/$(EXECUTABLE)
    
clean:
	rm -f $(DB) 
