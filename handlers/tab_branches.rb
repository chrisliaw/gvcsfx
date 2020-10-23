

module GvcsFx
  module TabBranches

    def init_tab_branches

      @lstBranches.add_event_handler(javafx.scene.input.MouseEvent::MOUSE_CLICKED, Proc.new do |evt|
        if evt.button == javafx.scene.input.MouseButton::SECONDARY
          # right click on item
          branches_ctxmenu.show(@lstBranches, evt.screen_x, evt.screen_y)
        #elsif evt.button == javafx.scene.input.MouseButton::PRIMARY and evt.click_count == 2
        #  # double click on item - view file
        #  sel = @tblChanges.selection_model.selected_items
        #  if sel.length > 0
        #    sel.each do |s|
        #      fullPath = File.join(@selWs.path,s.path.strip)
        #      if not File.directory?(fullPath)
        #        view_file(s.path)
        #      end
        #    end
        #  end

        end
      end)
      
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


    def branches_ctxmenu
      
      @selBranch = @lstBranches.selection_model.selected_items

      @branchesCtxMenu = javafx.scene.control.ContextMenu.new

      if @selBranch.length > 0

        st, currBranch = @selWs.current_branch

        if st

          selBr = @selBranch.first
          if not is_current_branch(selBr)

            mergeMnuItm = javafx.scene.control.MenuItem.new("Merge with #{currBranch}")
            mergeMnuItm.on_action do |evt|
              
              res = fx_alert_confirmation("Merge changes in branch '#{selBr}' into '#{currBranch}'?", nil, "Confirmation to Merge Branches", main_stage)
              if res == :ok
                st,res = @selWs.merge_branch(selBr)
                if st
                  set_info_gmsg("Branch '#{selBr}' merged into '#{currBranch}' successfully.")
                else
                  log_error("Merge branch '#{selBr}' inito '#{currBranch}' failed. [#{res}]")
                  set_err_gmsg("Merge branch '#{selBr}' inito '#{currBranch}' failed. [#{res}]")
                end
              end # if user answer ok to merge


            end  # on_action do .. end

            @branchesCtxMenu.items.add(mergeMnuItm)


            @branchesCtxMenu.items.add(javafx.scene.control.SeparatorMenuItem.new)

            delMnuItm = javafx.scene.control.MenuItem.new("Delete branch")
            delMnuItm.on_action do |evt|
              
              res = fx_alert_confirmation("Delete branch '#{selBr}'?", nil, "Confirmation to Delete Branch", main_stage)
              if res == :ok
                st,res = @selWs.delete_branch(selBr)
                if st
                  set_info_gmsg("Branch '#{selBr}' deleted successfully.")
                  refresh_tab_branches
                else
                  log_error("Delete branch '#{selBr}' failed. [#{res}]")
                  set_err_gmsg("Delete branch '#{selBr}' failed. [#{res}]")
                end
              end # if user answer ok to delete


            end  # on_action do .. end

            @branchesCtxMenu.items.add(delMnuItm)


          end # if selected branch is not current branch

        else
          set_err_gmsg("Failed to get current branch for context menu construction. [#{currBranch}]")
        end

      end

      @branchesCtxMenu
      
    end

    def is_current_branch(br)
      if is_empty?(br)
        false
      else
        (br =~ /\*/) != nil
      end
    end

  end
end
