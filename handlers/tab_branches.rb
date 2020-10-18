

module GvcsFx
  module TabBranches

    def init_tab_branches
      
    end

    def refresh_tab_branches
     
      @lstBranches.items.clear

      st, br = @selWs.all_branches
      if st
        @lstBranches.items.add_all(br)
      end
      
      @txtNewBranchName.clear
    end # refresh_tab_branches

    def create_branch(evt)

      bn = @txtNewBranchName.text
      if is_empty?(bn)
        fx_alert_error("Branch name cannot be empty","Empty Branch Name",main_stage)
      else
        st, res = @selWs.create_branch(bn)
        if st
          fx_alert_info("New branch '#{bn}' successfully created.","New Branch Created",main_stage)
          refresh_tab_branches
        else
          fx_alert_error(res.strip,"New Branch Creation Failed", main_stage)
        end
      end
    end # create_branch

    def branch_clicked(evt)
      if evt.button == javafx.scene.input.MouseButton::PRIMARY and evt.click_count == 2
        selBr = @lstBranches.selection_model.selected_item  
        if not_empty?(selBr)
          # switch branch
          st, res = @selWs.switch_branch(selBr)
          refresh_tab_branches
        end
      end
    end

  end
end
