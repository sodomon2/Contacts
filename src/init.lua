#!/usr/bin/env lua5.1

package.path = package.path .. ';./?/init.lua;lib/?.lua'
require 'lib'

require ("tray")
require ("contact")
require ("app")
require ("users")

function notification(title,msg)
		Notify.init("init")
		message = Notify.Notification.new
		msg = message(title,msg)
		msg:show()
end

ui.dialog_login:show_all()
Gtk.main()
