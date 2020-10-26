


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
