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


java_import javafx.scene.control.ContextMenu

require_relative "main_win_controller"

module GvcsFx
  class FloatWinController
    include JRubyFX::Controller
    fxml "float.fxml"

    def initialize
    end


    def show_context_menu(evt)
      init_ctxmenu.show(@imgFloat, evt.screen_x, evt.screen_y) 
    end


    private
    def init_ctxmenu

      if @ctx.nil?

        @ctx = ContextMenu.new
        mnuItems = []
        @mnuMain = javafx.scene.control.MenuItem.new("G-VCS")
        @mnuMain.on_action do |evt|
         stage = javafx.stage.Stage.new
          stage.title = "G-VCS"
          #stage.initModality(javafx.stage.Modality::WINDOW_MODAL)
          #stage.initOwner(@imgFloat.scene.window)
          ctrl = MainWinController.load_into(stage)
          stage.show
        end
        mnuItems << @mnuMain

        @mnuExit = javafx.scene.control.MenuItem.new("Exit")
        @mnuExit.on_action do |evt|
          @imgFloat.scene.window.close 
        end
        mnuItems << @mnuExit

        @ctx.items.add_all(mnuItems)

      end

      @ctx
    end

  end
end
