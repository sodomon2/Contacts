# Copyright (c) 2020-2021  Díaz  Urbaneja Victor Diego Alejandro  aka  (Sodomon)
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.


SQLITE3     = /usr/bin/sqlite3
DB          = ./db.db
SCHEMA_DB   = ./data/database/schema.sql
EXECUTABLE  = ./data/contacts

all: db

db:
	$(SQLITE3) $(DB) < $(SCHEMA_DB)

install: 
	install -m775 $(EXECUTABLE) /usr/bin/
	mkdir -p /usr/share/contacts
	cp -r src/lib/ /usr/share/contacts
	cp -r data/contacts.ui /usr/share/contacts/data/contacts.ui
	cp -r src/init.lua /usr/share/contacts
	install -m644 $(DB) /usr/share/contacts
	install -m644 data/contacts.desktop /usr/share/applications
   
uninstall:
	rm -r /usr/share/contacts
	rm -f /usr/share/applications/contacts.desktop
	rm -f /usr/bin/$(EXECUTABLE)
    
clean:
	rm -f $(DB) 
