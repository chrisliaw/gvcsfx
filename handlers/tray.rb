# Copyright (C) 2020  Chris Liaw <chrisliaw@antrapol.com>
# Author: Chris Liaw <chrisliaw@antrapol.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.


java_import java.awt.AWTException
java_import java.awt.Menu
java_import java.awt.MenuItem
java_import java.awt.PopupMenu
java_import java.awt.SystemTray
java_import java.awt.TrayIcon
java_import java.awt.event.ActionEvent
java_import java.awt.event.ActionListener
java_import javax.swing.ImageIcon
java_import javax.swing.JOptionPane

java_import javax.swing.JPopupMenu
java_import javax.swing.JMenu
java_import javax.swing.JMenuItem

require_relative "../lib/global"
require_relative '../lib/log_helper'

module GvcsFx
  module Tray
    include GvcsFx::LogHelper

    def start_tray(app = nil)
      
      if SystemTray.isSupported

				begin

					Java::JavaxSwing::UIManager.setLookAndFeel(Java::JavaxSwing::UIManager.getSystemLookAndFeelClassName())

					tray = SystemTray.getSystemTray
					popup = JPopupMenu.new
					if inside_jar?
						icon = TrayIcon.new(java.awt.Toolkit::default_toolkit.get_image(java.lang.Object.new.java_class.resource("/gvcs_fx/res/version-control.png")),"G-VCS")
					else
						icon = TrayIcon.new(ImageIcon.new(File.join(File.dirname(__FILE__),"..","res","version-control.png")).getImage,"G-VCS")
					end

					mainAct = JMenuItem.new("G-VCS")
				  mainAct.add_action_listener do |evt|
            
            #javafx.application.Platform.run_later do
              #puts "Inside run later!"
              #begin
              #  app.show_stage
              #rescue Exception => ex
              #  puts ex
              #  #log_error(ex.message)
              #end
            #end
            #puts "after run_later"
					end
					popup.add(mainAct)

					popup.addSeparator

					aboutItm = JMenuItem.new("About")
					aboutItm.add_action_listener do |evt|
					end
					popup.add(aboutItm)

					exitItm = JMenuItem.new("Exit")
					exitItm.add_action_listener do |evt|
						ans = JOptionPane::showConfirmDialog(nil,"Exit G-VCS?","Exit Confirmation",JOptionPane::YES_NO_OPTION,JOptionPane::QUESTION_MESSAGE)
						if ans == JOptionPane::YES_OPTION
             
              javafx.application.Platform.exit

              SystemTray.getSystemTray.remove(icon)
							java.lang.System.exit(0)
						end
					end
					popup.add(exitItm)

          # if using this approach the pop up menu will not OS native look...
					#icon.setPopupMenu(popup)
          # https://stackoverflow.com/a/17258735
          icon.add_mouse_listener do |evt|
            if (evt.getID == java.awt.event.MouseEvent::MOUSE_CLICKED) 
              # isPopupTrigger is recommended if the moust event is mousePressed
              #if evt.isPopupTrigger
                popup.setLocation(evt.getX(),evt.getY())
                popup.setInvoker(popup)
                popup.visible = true
              #end
            end
          end

          icon.setImageAutoSize(true)
					tray.add(icon)

				rescue Exception => ex
					STDERR.puts ex.backtrace.join("\n")
          #log_error(ex.message)
          #fx_alert_error ex.message, "G-VCS Tray Startup Exception"
				end
        
      else
        Global.instance.debug "No tray support"
        #fx_alert_error("No tray support for this platform")
      end

    end # show_tray

    def inside_jar?
      File.dirname(__FILE__)[0..3] == "uri:"
    end


  end # module Tray
end
