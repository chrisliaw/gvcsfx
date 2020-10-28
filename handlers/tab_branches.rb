

module GvcsFx
  module TabBranches

    class VcsStash < Hash

      def to_s
      end
    end

    class VcsBranch
      include Antrapol::ToolRack::ExceptionUtils

      attr_accessor :name, :stash, :current
      def initialize
        @name = ""
        @stash = VcsStash.new
        @current = false
      end

      def name=(val)
        if not_empty?(val)
          if val =~ /\*/
            @current = true
            @name = val.gsub("*","").strip
          else
            @name = val
          end
        end
      end

      def to_s
        res = []
        res << "#{(@current ? "* #{@name}" : @name)}"
        if not_empty?(@stash)
          res << "(#{@stash.length} stash(es) on this branch found)"
        end
        res.join(" ")
      end
    end # VcsBranch

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

      st, br = @selWs.local_branches
      if st
        sst, sinfo = @selWs.stash_list
        if sst

          bbr = { }
          br.each do |b|
            vb = VcsBranch.new
            vb.name = b
            bbr[vb.name] = vb
          end

          sinfo.each do |k,v|
            if bbr.keys.include?(v[0])
              bbr[v[0]].stash[k] = v
            end
          end

          @lstBranches.items.add_all(bbr.values)

        else
          @lstBranches.items.add_all(br)
        end
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
          set_success_gmsg("New branch '#{bn}' successfully created.")
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
          if selBr.current #is_current_branch(selBr)
          else
            # switch branch
            st, res = @selWs.switch_branch(selBr.name)
            if st
              set_info_gmsg("Workspace's branch switched to '#{selBr.name}'")
              refresh_tab_branches
            else
              prompt_error("Failed to switch to branch '#{selBr.name}'. Error was :\n\n#{res}")
            end
          end
        end
      end
    end

    # hooked on text field of new branch
    def new_branch_keypressed(evt)
      if evt.code == javafx.scene.input.KeyCode::ENTER
        create_branch(nil)
      end
    end

    def show_stash_restore_win(options, stageTitle = "GVCS - Stash Restore")

      #javafx.application.Platform.run_later do

        stage = javafx.stage.Stage.new
        stage.title = stageTitle
        stage.initModality(javafx.stage.Modality::WINDOW_MODAL)
        stage.initOwner(main_stage)
        dlg = StashSelectController.load_into(stage)
        dlg.options = options
        stage.showAndWait

        dlg.result
      #end # run_later

    end # show_options_win


    def branches_ctxmenu
      
      @selBranch = @lstBranches.selection_model.selected_items

      @branchesCtxMenu = javafx.scene.control.ContextMenu.new

      if @selBranch.length > 0

        selBr = @selBranch.first
        bst, currBranch = @selWs.current_branch


        if not selBr.current #is_current_branch(selBr)


          mergeMnuItm = javafx.scene.control.MenuItem.new("Merge with #{currBranch}")
          mergeMnuItm.on_action do |evt|

            res = fx_alert_confirmation("Merge changes in branch '#{selBr.name}' into '#{currBranch}'?", nil, "Confirmation to Merge Branches", main_stage)
            if res == :ok
              st,res = @selWs.merge_branch(selBr.name)
              if st
                set_success_gmsg("Branch '#{selBr.name}' merged into '#{currBranch}' successfully.")
              else
                log_error("Merge branch '#{selBr.name}' inito '#{currBranch}' failed. [#{res}]")
                prompt_error("Merge branch '#{selBr.name}' inito '#{currBranch}' failed. [#{res}]")
              end
            end # if user answer ok to merge


          end  # on_action do .. end

          @branchesCtxMenu.items.add(mergeMnuItm)


          @branchesCtxMenu.items.add(javafx.scene.control.SeparatorMenuItem.new)

          delMnuItm = javafx.scene.control.MenuItem.new("Delete branch")
          delMnuItm.on_action do |evt|

            res = fx_alert_confirmation("Delete branch '#{selBr.name}'?", nil, "Confirmation to Delete Branch", main_stage)
            if res == :ok
              st,res = @selWs.delete_branch(selBr.name)
              if st
                set_success_gmsg("Branch '#{selBr.name}' deleted successfully.")
                refresh_tab_branches
              else
                log_error("Delete branch '#{selBr.name}' failed. [#{res}]")
                prompt_error("Delete branch '#{selBr.name}' failed. [#{res}]")
              end
            end # if user answer ok to delete


          end  # on_action do .. end

          @branchesCtxMenu.items.add(delMnuItm)

        else
          #@branchesCtxMenu.items.add(javafx.scene.control.SeparatorMenuItem.new) if @branchesCtxMenu.items.count > 0

          #if not_empty?(selBr.stash)

          #  lsMnuItm = javafx.scene.control.MenuItem.new("Restore Stash to new branch")
          #  lsMnuItm.on_action do |evt|

          #    st, sel, branch = show_stash_restore_win(selBr.stash)
          #    if st
          #      if is_empty?(sel)
          #        prompt_error("Please select one of the Stash to restore.","Empty Stash Selection")
          #      elsif is_empty?(branch)
          #        prompt_error("Please provide a branch name.","Empty Branch Name")
          #      else
          #        sst, sres = @selWs.stash_to_new_branch(branch, sel.key)

          #        if sst
          #          set_success_gmsg(sres)
          #        else
          #          prompt_error("Failed to store the stash to #{currBranch}. Error was : #{sres}")
          #        end
          #      end
          #    end

          #  end  # on_action do .. end

          #  @branchesCtxMenu.items.add(lsMnuItm)

          #end
 
        end # if selected branch is not current branch


        if not_empty?(selBr.stash)

          @branchesCtxMenu.items.add(javafx.scene.control.SeparatorMenuItem.new) if @branchesCtxMenu.items.count > 0

          lsMnuItm = javafx.scene.control.MenuItem.new("Restore Stash to new branch")
          lsMnuItm.on_action do |evt|
            
              st, sel, branch = show_stash_restore_win(selBr.stash)
              if st
                if is_empty?(sel)
                  prompt_error("Please select one of the Stash to restore.","Empty Stash Selection")
                elsif is_empty?(branch)
                  prompt_error("Please provide a branch name.","Empty Branch Name")
                else
                  sst, sres = @selWs.stash_to_new_branch(branch, sel.key)

                  if sst
                    set_success_gmsg(sres)
                    refresh_tab_branches
                  else
                    prompt_error("Failed to restore the stash '#{sel.key}' to new branch #{branch}. Error was : #{sres}")
                  end
                end
              end

          end  # on_action do .. end

          @branchesCtxMenu.items.add(lsMnuItm)
        
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
