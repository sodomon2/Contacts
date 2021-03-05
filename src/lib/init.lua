#!/usr/bin/lua5.1
--[[--
 @package   Contact
 @filename  lib/init.lua  
 @version   3.0
 @author    Diaz Urbaneja Victor Diego Alejandro <sodomon2@gmail.com> 
 @date      04.03.2021 22:43:42 -04
--]]

require('lib.middleclass')
db        = require('lib.db')

lgi       = require 'lgi'
GObject   = lgi.require('GObject','2.0')
Gdk       = lgi.require('Gdk', '3.0')
GLib      = lgi.require('GLib', '2.0')
Notify    = lgi.require('Notify')
Gtk       = lgi.require('Gtk', '3.0')

builder   = Gtk.Builder()
builder:add_from_file('../data/contacts.ui')
ui = builder.objects

print('Libraries loaded successfully.')