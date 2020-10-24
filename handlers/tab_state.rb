
require_relative 'show_text_controller'

module GvcsFx
  module TabState

    ###########
    class VcsElement
      attr_accessor :ctype, :path, :ftype
      def initialize(ctype, path, ftype)
        @ctype = ctype
        @path = path
        @ftype = ftype
      end
    end
    class ModifiedFile < VcsElement
      def initialize(path, ftype)
        super("M",path, ftype)
      end
    end
    class NewFile < VcsElement
      def initialize(path, ftype)
        super("N",path, ftype)
      end
    end
    class DeletedFile < VcsElement
      def initialize(path, ftype)
        super("D",path, ftype)
      end
    end
    #############

    def init_tab_state
      @tblChanges.placeholder = javafx.scene.control.Label.new("Changeset is empty. Please select a workspace or the selected workspace has no changes ")

      @tblChanges.columns.clear
      @tblChanges.column_resize_policy = javafx.scene.control.TableView::CONSTRAINED_RESIZE_POLICY

      cols = []
      colState = TableColumn.new("State")
      colState.cell_value_factory = Proc.new do |p|
        SimpleStringProperty.new(p.value.ctype)
      end
      cols << colState
      
      colUrl = TableColumn.new("Path")
      colUrl.cell_value_factory = Proc.new do |p|
        SimpleStringProperty.new(p.value.path)
      end
      cols << colUrl

      @tblChanges.columns.add_all(cols)

      # set column width
      #colState.pref_width_property.bind(@tblChanges.width_property.multiply(0.1))
      #colState.max_width_property.bind(colState.pref_width_property)
      #colState.resizable = false
      colState.pref_width = 80.0
      colState.max_width = 100.0
      colState.min_width = 60.0

      @tblChanges.selection_model.selection_mode = javafx.scene.control.SelectionMode::MULTIPLE

      # mouse event
      @tblChanges.add_event_handler(javafx.scene.input.MouseEvent::MOUSE_CLICKED, Proc.new do |evt|
        if evt.button == javafx.scene.input.MouseButton::SECONDARY
          # right click on item
          changes_ctxmenu.show(@tblChanges, evt.screen_x, evt.screen_y)
        elsif evt.button == javafx.scene.input.MouseButton::PRIMARY and evt.click_count == 2
          # double click on item - diff file
          sel = @tblChanges.selection_model.selected_items
          if sel.length > 0
            sel.each do |s|
              st, res = @selWs.diff_file(s.path)
              if st

                show_content_win("Diff Output", "Diff Result - #{s.path}", res)

              else
                set_err_gmsg("Diff for '#{s.path}' failed. [#{res}]")
              end

            end
          end

        end
      end) # end mouse event

    end

    # hooked to but Commit on action
    def vcs_commit(evt)
      sel = @tblChanges.selection_model.selected_items
      msg = @cmbCommitMsg.value
      if sel.length == 0
        fx_alert_error "Cannot commit on empty changes selection. Please select at least a file from the table above.", "No Files Selected", main_stage
      elsif (msg.nil? or msg.empty?)
        fx_alert_error "Commit message must be present.", "Empty Commit Message", main_stage
      else
        commit_changes(sel, msg)
        refresh_tab_state
      end
    end

    # hooked to but Refresh on action
    def refresh_vcs_status(evt = nil)
      
      if not (@selWs.nil?)

        mst, mods_dirs, mods_files = @selWs.modified_files
        nst, news_dirs, news_files = @selWs.new_files
        dst, dels_dirs, dels_files = @selWs.deleted_files

        data = []
        mods_dirs.each do |f|
          data << ModifiedFile.new(f,:dir)
        end
        mods_files.each do |f|
          data << ModifiedFile.new(f,:file)
        end
        news_dirs.each do |f|
          data << NewFile.new(f,:dir)
        end
        news_files.each do |f|
          data << NewFile.new(f,:file)
        end
        dels_dirs.each do |f|
          data << DeletedFile.new(f,:dir)
        end
        dels_files.each do |f|
          data << DeletedFile.new(f,:file)
        end

        bst, currBranch = @selWs.current_branch
        if bst
          @lblCurrBranch.text = currBranch
        else
          @lblCurrBranch.text = "<Exception while reading branch [#{currBranch}]>"
        end


        @tblChanges.items.clear
        @tblChanges.items.add_all(data)
      end

    end

    def refresh_tab_state
      refresh_vcs_status(nil)
      @cmbCommitMsg.selection_model.clear_selection
      @cmbCommitMsg.value = nil
    end

    # hooked to on_key_typed
    def is_cmbCommit_enter(evt)
      if (not evt.nil?) and evt.code == javafx.scene.input.KeyCode::ENTER
        vcs_commit(nil)
      end
    end

    # hooked to the button "not ready to commit just yet..."
    def stash_changes(evt)
      mst, mods_dirs, mods_files = @selWs.modified_files
      nst, news_dirs, news_files = @selWs.new_files
      dst, dels_dirs, dels_files = @selWs.deleted_files

      if mods_dirs.length > 0 or mods_files.length > 0 \
          or news_dirs.length > 0 or news_files.length > 0 \
          or dels_dirs.length > 0 or dels_files.length > 0

        msg = []
        msg << "System detected there are existing uncommitted changes in the current workspace:\n"
        msg << "\tModified folder(s) : \t#{mods_dirs.length}\n"
        msg << "\tModified file(s) : \t#{mods_files.length}\n"
        msg << "\tDeleted folder(s) : \t#{dels_dirs.length}\n"
        msg << "\tDeleted file(s) : \t#{dels_files.length}\n"
        msg << "\tNew folder(s) : \t#{news_dirs.length}\n"
        msg << "\tNew file(s) : \t\t#{news_files.length}\n"

        st, name = fx_alert_input("Temporary Save Changes",msg.join, "Please give a descriptive name of this temporary changes.\nIt is recommended but not mandatory")
        if st
          # this means user click ok, but the text can still be empty
          sst, res = @selWs.stash_changes(name)
          if sst
            set_info_gmsg(res)
            refresh_vcs_status
          else
            prompt_error("Failed to stash the changes. Error was : #{res}")
          end 
        end

      else
        fx_alert_info("Workspace is clean. No uncommitted changes found")
      end
    end

    private
    def commit_changes(selected, msg) 
      raise_if_empty(selected, "No file given to commit", GvcsFxException)  
      raise_if_empty(msg, "No message given to commit", GvcsFxException)  

      @emptyDirCommit = []
      @processed = []
      selected.each do |f|
        begin
          fullPath = File.join(@selWs.path,f.path.strip)
          if File.directory?(fullPath)
            # check if the directory is empty...
            if Dir.entries(fullPath).length == 2
              # empty!
              keepPath = File.join(fullPath,".keep")
              FileUtils.touch keepPath

              @selWs.add(keepPath)
              @emptyDirCommit << File.join(f.path.strip,".keep")
            else
              @selWs.add(f.path)
              @processed << f.path.strip
            end
          else
            @selWs.add(f.path) 
            @processed << f.path.strip
          end
        rescue Exception => ex
          log_error "Error while GVCS add to staging operation:"
          log_error ex.message
          log_error ex.backtrace.join("\n")
          reset_add_commit_error(@processed,@emptyDirCommit)
        end
      end

      begin
        cst, res = @selWs.commit(msg)
        if !cst
          reset_add_commit_error(@processed,@emptyDirCommit)
          #fx_alert_error("Error while committing changes. Error was:\n#{res.strip}", "Commit Error", GvcsFxException)
          set_err_gmsg("Error while committing changes. Error was:\n#{res.strip}")
        end
      rescue Exception => ex;
        reset_add_commit_error(@processed,@emptyDirCommit)
      end
    end

    def reset_add_commit_error(files, emptyFolders = [])

      if not_empty?(files)
        files.each do |f|
          begin
            @selWs.remove_from_staging(f)
          rescue Exception => ex
            log_error "Exception while removing file from staging. Error was: "
            log_error ex.message
            log_error ex.backtrace[0..5].join("\n")
          end
        end
      end

      if not_empty?(emptyFolders)
        emptyFolders.each do |f|
          @selWs.remove_from_staging(f)
          # not removing the created .keep file because it is an exception case
          # Exception case doesn't mean the intention to check in the directory is incorrect.
          # the intention to check in still there therefore the .keep file shall remain
        end
      end
      
    end # reset_add_commit_error

    def view_file(path)

      javafx.application.Platform.run_later do
        stage = javafx.stage.Stage.new
        stage.title = "View Content"
        stage.initModality(javafx.stage.Modality::WINDOW_MODAL)
        #stage.initOwner(main_stage)
        dlg = ShowTextController.load_into(stage)
        dlg.set_title("File Content - #{path}")
        File.open(File.join(@selWs.path,path),"r") do |f|
          @cont = f.read
        end
        dlg.set_content(@cont)
        stage.showAndWait
      end

    end

    def changes_ctxmenu

      @selChanges = @tblChanges.selection_model.selected_items


      @changesCtxMenu = javafx.scene.control.ContextMenu.new

      if @selChanges.length > 0

        # 
        # View file menu item
        #
        vfMnuItm = javafx.scene.control.MenuItem.new("View file")
        vfMnuItm.on_action do |evt|

          @selChanges.each do |s|

            fullPath = File.join(@selWs.path,s.path.strip)
            if not File.directory?(fullPath)
              view_file(s.path)
            end

          end

        end
        @changesCtxMenu.items.add(vfMnuItm)
        # 
        # end diff menu item
        #

        # 
        # Remove from VCS
        #
        @changesCtxMenu.items.add(javafx.scene.control.SeparatorMenuItem.new)

        rmvVcsMnuItm = javafx.scene.control.MenuItem.new("Remove from VCS")
        rmvVcsMnuItm.on_action do |evt|

          @selChanges.each do |s|
            @selWs.remove_from_vcs(s.path)
            @selWs.ignore(s.path)

            set_info_gmsg("File '#{s.path}' removed from VCS")
          end

          refresh_vcs_status(nil)

        end
        @changesCtxMenu.items.add(rmvVcsMnuItm)
        # 
        # end remove from VCS
        #

        #delMnuItm = javafx.scene.control.MenuItem.new("Delete physical file")
        #delMnuItm.on_action do |evt|
        #  puts "Del physical file"
        #end
        #@changesCtxMenu.items.add(delMnuItm)

        @changesCtxMenu.items.add(javafx.scene.control.SeparatorMenuItem.new)

        # 
        # Add to ignore list
        #
        ignMnuItm = javafx.scene.control.MenuItem.new("Add to ignore list")
        ignMnuItm.on_action do |evt|

          igPat = []
          @selChanges.each do |s|
            fullPath = File.join(@selWs.path, s.path)
            if File.directory?(fullPath)

              res = fx_alert_confirmation("Add folder '#{s.path}' to ignore list?\nAll changes under this folder shall be ignored if done so.", nil, "Confirmation to Ignore Directory", main_stage)
              if res == :ok
                # is the folder already in version control?
                if s.is_a?(NewFile)
                  igPat << s.path
                elsif s.is_a?(DeletedFile)
                  fx_alert_info("Folder '#{s.path}' is marked deleted but not yet committed.\nFolder shall be put inside ignore rules but shall only reflect after you've committed the changes.")
                  igPat << s.path
                elsif s.is_a?(ModifiedFile)
                  res = fx_alert_confirmation("Folder being ignored is already tracked under the VCS.\nRemove folder from VCS and put it under ignore rule?", nil, "Confirmation to Ignore Tracked Folder", main_stage)
                  if res == :ok
                    @selWs.remove_from_vcs(s.path)
                    igPat << s.path
                  end
                end

                cnt = igPat.join("\n")
                st, res = @selWs.ignore(cnt)

                if st
                  set_success_gmsg(res)
                  refresh_vcs_status(nil)
                else
                  set_err_gmsg("Add to ignore list for '#{igPat.join(",")}' failed. [#{res}]")
                end

              end # res == :0k

            else
              # is the file already in version control?
              if s.is_a?(NewFile)
                igPat << s.path
              elsif s.is_a?(DeletedFile)
                  fx_alert_info("File '#{s.path}' is marked deleted but not yet committed.\nFile shall be put inside ignore rules but shall only reflect after you've committed the changes.")
                  igPat << s.path
              elsif s.is_a?(ModifiedFile)
                res = fx_alert_confirmation("File being ignored is already tracked under the VCS.\nRemove file from VCS and put it under ignore rule?", nil, "Confirmation to Ignore Tracked File", main_stage)
                if res == :ok
                  @selWs.remove_from_vcs(s.path)
                  igPat << s.path
                end
              end

              cnt = igPat.join("\n")
              st, res = @selWs.ignore(cnt)

              if st
                set_success_gmsg(res)
                refresh_vcs_status(nil)
              else
                set_err_gmsg("Add to ignore list for '#{igPat.join(",")}' failed. [#{res}]")
              end

            end
          end

          #cnt = igPat.join("\n")
          #st, res = @selWs.ignore(cnt)

          #if st
          #  refresh_vcs_status(nil)
          #else
          #  set_err_gmsg("Add to ignore list for '#{igPat.join(",")}' failed. [#{res}]")
          #end

        end
        @changesCtxMenu.items.add(ignMnuItm)
        #
        # end Add to ignore list
        #

        # 
        # Add extension to ignore list
        #
        ignExtMnuItm = javafx.scene.control.MenuItem.new("Add extension to ignore list")
        ignExtMnuItm.on_action do |evt|

          igPat = []
          @selChanges.each do |s|
            fullPath = File.join(@selWs.path, s.path)
            if File.directory?(fullPath)
              fx_alert_warning("Given file '#{s.path}' to add extension to ignore list is a folder.\nPlease use 'Add to ignore list' option if indeed that is the intention.","Folder has no extension",main_stage)
            else
              igPat << "*#{File.extname(s.path)}"
            end
          end

          cnt = igPat.join("\n")
          st, res = @selWs.ignore(cnt)

          if st
            refresh_vcs_status(nil)
          else
            set_err_gmsg("Add extension '#{igPat.join(",")}' to ignore list failed. [#{res}]")
          end

        end
        @changesCtxMenu.items.add(ignExtMnuItm)
        #
        # end Add extension to ignore list
        #

        @changesCtxMenu.items.add(javafx.scene.control.SeparatorMenuItem.new)

        # 
        # Revert changes
        #
        revertExtMnuItm = javafx.scene.control.MenuItem.new("Revert Changes")
        revertExtMnuItm.on_action do |evt|

          igPat = []
          @selChanges.each do |s|
            res = fx_alert_confirmation("Revert '#{s.path}' to version from last commit?\nAll changes made to the fill will be discarded!.", nil, "Confirmation to Revert Changes", main_stage)
            if res == :ok
              igPat << s.path
            end

          end

          cnt = igPat.join("\n")
          st, res = @selWs.reset_file_changes(cnt)

          if st
            set_info_gmsg(res)
            refresh_vcs_status(nil)
          else
            set_err_gmsg("Add extension '#{igPat.join(",")}' to ignore list failed. [#{res}]")
          end

        end
        @changesCtxMenu.items.add(revertExtMnuItm)
        #
        # end Add extension to ignore list
        #


      end


      @changesCtxMenu 
      
    end

  end
end
