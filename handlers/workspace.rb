
require_relative '../lib/store'

java_import javafx.scene.control.cell.PropertyValueFactory
java_import javafx.scene.control.TableColumn
java_import javafx.collections.FXCollections
java_import javafx.beans.property.SimpleStringProperty

module GvcsFx
  module Workspace

    def init_tblWorkspace
      @tblWorkspaces.placeholder = javafx.scene.control.Label.new("Add a workspace to begin")

      @tblWorkspaces.columns.clear
      @tblWorkspaces.column_resize_policy = javafx.scene.control.TableView::CONSTRAINED_RESIZE_POLICY

      #colName = TableColumn.new("Name")
      #colName.cell_value_factory = Proc.new do |p|
      #  SimpleStringProperty.new(p.value.name)
      #end
      #colName.cell_factory = Proc.new do
      #  tblCell = WorkspaceTableCell.new
      #  tblCell
      #end
      
      colUrl = TableColumn.new("Path")
      colUrl.cell_value_factory = Proc.new do |p|
        SimpleStringProperty.new(p.value.path)
      end

      colAccess = TableColumn.new("Last Access")
      colAccess.cell_value_factory = Proc.new do |p|
        SimpleStringProperty.new(p.value.last_access)
      end

      colAccess.pref_width = 180.0
      colAccess.max_width = colAccess.pref_width
      colAccess.min_width = colAccess.pref_width

      @tblWorkspaces.columns.add_all([colUrl, colAccess])

      @tblWorkspaces.selection_model.selection_mode = javafx.scene.control.SelectionMode::SINGLE

      @tblWorkspaces.selection_model.selected_items.add_listener do |evt|
        sel = @tblWorkspaces.selection_model.selected_items.to_a
        if sel.length > 0
          selWs = sel.first
          # Here shall set a global reference to the selected workspace @selWs
          @selWs = Gvcs::Workspace.new(Global.instance.vcs, selWs.path) 
          
          refresh_details

          show_details
        else
          show_landing
        end
      end

      refresh_workspace_list

    end

    def workspace_add(evt)

      path = @txtWorkspacePath.text
      if not_empty?(path)

        if not File.exist?(path)
          prompt_error("Given path '#{path}' does not exist. Please make sure it is a valid path.","Given Path Invalid",main_stage)
        else

          vcs = Gvcs::Vcs.new
          tws = Gvcs::Workspace.new(vcs, path)
          if not tws.is_workspace?
            vcs.init(path)
          end

          ds = Global.instance.storage
          ds.add_workspace("",path)
          ds.store

          refresh_workspace_list
          @txtWorkspacePath.clear

        end

      else
        prompt_error "Please provide a folder path before Add operation", "Empty Path", main_stage
      end
      
    end

    def workspace_dnd_dropped(evt)
      dnd_dropped(evt)
      evt.drop_completed = true
    end

    def workspace_dnd_over(evt)
      evt.acceptTransferModes(javafx.scene.input.TransferMode::LINK)
    end

    def landing_dnd_dropped(evt)
      dnd_dropped(evt)
      evt.drop_completed = true
    end

    def landing_dnd_over(evt)
      evt.acceptTransferModes(javafx.scene.input.TransferMode::LINK)
    end

    def refresh_workspace_list
      db = Global.instance.storage

      @tblWorkspaces.items.clear

      log_debug "#{db.workspaces.length} workspace(s) found"

      @tblWorkspaces.items.add_all(db.workspaces)

      if db.workspaces.length > 0
        show_details
      else
        show_landing
      end

    end
    
    def show_details
      @pnlLanding.visible = false
      @tabPnlDetails.visible = true
    end

    def show_landing
      @pnlLanding.visible = true
      @tabPnlDetails.visible = false
    end

    def workspace_key_released(evt)
      if evt.code == javafx.scene.input.KeyCode::DELETE
        sel = @tblWorkspaces.selection_model.selected_items.to_a
        if sel.length > 0
          s = sel.first.path
          res = fx_alert_confirmation("Delete workspace '#{s}' from system?\nThis won't affect physical file.", nil, "Remove Path from Management?", main_stage)
          if res == :ok
            Global.instance.storage.remove_workspace(s)
            Global.instance.storage.store
            refresh_workspace_list
            refresh_details
            log_debug "Workspace '#{s}' removed from management"
            set_info_gmsg("Workspace '#{s}' removed from management")
          else
            set_err_gmsg("Workspace delete operation aborted")
          end
        end

      end 
    end

    def open_workspace(evt)
      dc = javafx.stage.DirectoryChooser.new 
      dc.title = "Select VCS Workspace"
      wsDir = dc.showDialog(main_stage)

      @txtWorkspacePath.text = wsDir.absolute_path
    end

    private
    def dnd_dropped(evt)
      f = evt.dragboard.files
      vcs = Gvcs::Vcs.new
      ws = []
      nws = []
      f.each do |ff|
        log_debug "Checking drop in path '#{ff.absolute_path}'"
        st, path = Gvcs::Workspace.new(vcs, ff.absolute_path).workspace_root
        if st
          # workspace!
          ws << path.strip
        else
          # not a workspace
          nws << ff.absolute_path
        end
      end

      ds = Global.instance.storage
      ws.each do |w|
        log_debug "Adding workspace '#{w}'"
        ds.add_workspace(w,w)
      end 

      failed = { }
      nws.each do |w|
        log_debug "Adding non workspace '#{w}'"
        st, res = vcs.init(w)  
        if st
          ds.add_workspace(w,w)
        else
          failed[w] = res
        end
      end

      ds.store

      raise_event(Notifier::Event[:workspace_added])

      ds

    end # dnd_dropped

  end
end
