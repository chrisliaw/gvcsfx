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


module GvcsFx
  class AddWorkspaceController
    include JRubyFX::Controller
    include Antrapol::ToolRack::ExceptionUtils
    fxml "add_workspace.fxml"

    ADDPROJ_KEY = "<Add New Project>"

    attr_reader :result
    def initialize
      init
    end

    def init
      @cmbProject.items.add_all(["",ADDPROJ_KEY])
      hide_new_proj_entry
    end

    def add_option(opt)
      @cmbProject.items.add(opt)
    end

    def butOpen_onAction(evt)
      
    end # butOpen_onAction

    def cmbProj_onAction(evt)
      val = @cmbProject.selection_model.selected_item
      if not_empty?(val)
        if val == ADDPROJ_KEY
          show_new_proj_entry
        else
          hide_new_proj_entry
        end
      else
        hide_new_proj_entry
      end 
    end # cmbProj_onAction

    def butCreate_onAction(evt)
      @result = [@cmbProject.selection_model.selected_item, @txtNewProjName.text]
      @butOpen.scene.window.close
    end

    def butCancel_onAction(evt)
      @butOpen.scene.window.close
    end

    def path=(val)
      @lblWorkspacePath.text = val
    end

    def txtNewProjName_keyreleased(evt)
      if (not evt.nil?) and evt.code == javafx.scene.input.KeyCode::ENTER
        butCreate_onAction(nil)
      end
    end

    private
    def hide_new_proj_entry
      @lblNewProjName.visible = false
      @txtNewProjName.visible = false
    end

    def show_new_proj_entry
      @lblNewProjName.visible = true
      @txtNewProjName.visible = true
    end

  end
end
