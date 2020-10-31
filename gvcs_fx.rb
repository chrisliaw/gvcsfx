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


require 'jrubyfx'

require_relative "lib/version"

fxml_root File.join(File.dirname(__FILE__),"fx")

require_relative 'handlers/main_win_controller'
require_relative 'handlers/tray'
require_relative 'handlers/float_win_controller'

module GvcsFx
  class MainWin < JRubyFX::Application
    include GvcsFx::Tray

    attr_reader :stage
    def start(stage)
      
      @stage = stage
      #@stage.always_on_top = true
      #@stage.init_style = javafx.stage.StageStyle::UNDECORATED
      #javafx.application.Platform.implicit_exit = false

      # temporary disable for direct testing
      #with(stage, title: "G-VCS Float") do
      #  fxml FloatWinController
      #  show
      #end

      MainWinController.load_into(@stage)
      @stage.show

      # this is correct can show tray 
      # but hide/show javafx stage doesn't work
      #javax.swing.SwingUtilities.invokeLater do
      #  start_tray(self)
      #end

    end # start

    def show_stage
      javafx.application.Platform.run_later do
        puts "insite run_later #{@stage}"
        if not @stage.nil?
          @stage.show
          @stage.toFront
        end
      end
    end

    def hide_stage
      javafx.application.Platform.run_later do
        @stage.hide
      end
    end

  end
end

if $0 == __FILE__
  #puts "Launching"
  GvcsFx::MainWin.launch

  ## put swing code in its own event loop or the right click menu and the icon itself won't show 
  #event_thread = nil
  #javax.swing.SwingUtilities.invokeAndWait { event_thread = java.lang.Thread.currentThread }
  #event_thread.join
end

