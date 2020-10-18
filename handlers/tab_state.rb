
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

      @tblChanges.add_event_handler(javafx.scene.input.MouseEvent::MOUSE_CLICKED, Proc.new do |evt|
        if evt.button == javafx.scene.input.MouseButton::SECONDARY
          # right click on item
          changes_ctxmenu.show(@tblChanges, evt.screen_x, evt.screen_y)
        elsif evt.button == javafx.scene.input.MouseButton::PRIMARY and evt.click_count == 2
          # double click on item - view file
          sel = @tblChanges.selection_model.selected_items
          if sel.length > 0
            sel.each do |s|
              view_file(s.path)
            end
          end

        end
      end)

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
    def refresh_vcs_status(evt)
      
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
      if evt.code == javafx.scene.input.KeyCode::ENTER
        vcs_commit(nil)
      end
    end

    private
    def commit_changes(selected, msg) 
      raise_if_empty(selected, "No file given to commit", GvcsFxException)  
      raise_if_empty(msg, "No message given to commit", GvcsFxException)  

      selected.each do |f|
        begin
          @selWs.add(f.path)
        rescue Exception => ex
          log_error "Error while GVCS add to staging operation:"
          log_error ex.message
          begin
            @selWs.remove_from_staging(f.path)
          rescue Exception; end
        end
      end

      begin
        @selWs.commit(msg)
      rescue Exception => ex
        begin
          selected.each do |f|
            # this is unique because the GUI is grouping add and commit in single operation
            @selWs.remove_from_staging(f.path)
          end
        rescue Exception; end
      end
    end

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

      if @changesCtxMenu.nil?

        @changesCtxMenu = javafx.scene.control.ContextMenu.new
        
        diffMnuItm = javafx.scene.control.MenuItem.new("Diff")
        diffMnuItm.on_action do |evt|

          sel = @tblChanges.selection_model.selected_items
          if sel.length > 0
            sel.each do |s|

              st, res = @selWs.diff_file(s.path)
              if st
                javafx.application.Platform.run_later do
                  stage = javafx.stage.Stage.new
                  stage.title = "Diff Output"
                  stage.initModality(javafx.stage.Modality::WINDOW_MODAL)
                  #stage.initOwner(main_stage)
                  dlg = ShowTextController.load_into(stage)
                  dlg.set_title("Diff Result - #{s.path}")
                  dlg.set_content(res)
                  stage.showAndWait
                end

              end

            end
          end

        end
        @changesCtxMenu.items.add(diffMnuItm)

        #viewMnuItm = javafx.scene.control.MenuItem.new("View")
        #viewMnuItm.on_action do |evt|
        #  puts "View"
        #end
        #@changesCtxMenu.items.add(viewMnuItm)

        @changesCtxMenu.items.add(javafx.scene.control.SeparatorMenuItem.new)

        rmvVcsMnuItm = javafx.scene.control.MenuItem.new("Remove from VCS")
        rmvVcsMnuItm.on_action do |evt|

          sel = @tblChanges.selection_model.selected_items
          if sel.length > 0
            sel.each do |s|
              @selWs.remove_from_vcs(s.path)
              @selWs.ignore(s.path)
            end

            refresh_vcs_status(nil)
          end
          
        end
        @changesCtxMenu.items.add(rmvVcsMnuItm)

        delMnuItm = javafx.scene.control.MenuItem.new("Delete physical file")
        delMnuItm.on_action do |evt|
          puts "Del physical file"
        end
        @changesCtxMenu.items.add(delMnuItm)

        @changesCtxMenu.items.add(javafx.scene.control.SeparatorMenuItem.new)

        ignMnuItm = javafx.scene.control.MenuItem.new("Add to ignore list")
        ignMnuItm.on_action do |evt|

          sel = @tblChanges.selection_model.selected_items
          if sel.length > 0
            igPat = []
            sel.each do |s|
              igPat << s.path
            end

            cnt = igPat.join("\n")
            @selWs.ignore(cnt)

            refresh_vcs_status(nil)
          end

        end
        @changesCtxMenu.items.add(ignMnuItm)

        ignExtMnuItm = javafx.scene.control.MenuItem.new("Add extension to ignore list")
        ignExtMnuItm.on_action do |evt|
          sel = @tblChanges.selection_model.selected_items
          if sel.length > 0
            igPat = []
            sel.each do |s|
              igPat << "*#{File.extname(s.path)}"
            end

            cnt = igPat.join("\n")
            @selWs.ignore(cnt)

            refresh_vcs_status(nil)
          end

        end
        @changesCtxMenu.items.add(ignExtMnuItm)

      end

      @changesCtxMenu 
      
    end

  end
end
