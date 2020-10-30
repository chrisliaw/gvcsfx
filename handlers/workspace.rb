
require_relative '../lib/store'

java_import javafx.scene.control.cell.PropertyValueFactory
java_import javafx.scene.control.TreeTableColumn
java_import javafx.collections.FXCollections
java_import javafx.beans.property.SimpleStringProperty
java_import javafx.scene.control.TreeItem
java_import javafx.scene.text.Text
java_import javafx.application.Platform

module GvcsFx
  module Workspace

    class TreeWorkspace
      include javafx.beans.value.ObservableValue
   
      attr_accessor :project, :workspace

      def initialize(proj, ws)
        @project = proj
        @workspace = ws
      end

      def addListener(list)
      end

      def removeListener(list)
      end

      def value
        self
      end
    end

    class WorkspaceCellFactory < javafx.scene.control.TreeTableCell
      include Antrapol::ToolRack::ExceptionUtils
      def updateItem(itm,e)
        super

        cont = nil
        if not itm.nil? 
          if itm.is_a?(TreeWorkspace) 
            if not_empty?(itm.workspace)
              cont = itm.workspace.path
            elsif not_empty?(itm.project)
              cont = itm.project
            else
              cont = itm
            end
          else
            cont = itm
          end
        end

        setGraphic(Text.new(cont))

      end
    end


    LEAF_PROJ_DESC = "Leaf Workspaces (Workspace without bind to a project)"
    ALL_PROJ_FILTER = "All"
    def init_tblWorkspace
      
      @trtblWorkspace.columns.clear

      @trtblWorkspace.placeholder = javafx.scene.control.Label.new("Add a workspace to begin")

      @rootNode = TreeItem.new("Managed Workspaces")
      @rootNode.expanded = true

      # workspace that has not tie to any project
      @leafProj = TreeItem.new(LEAF_PROJ_DESC)

      @rootNode.children.add(@leafProj)

      col = []
      tcUrl = TreeTableColumn.new("Path")
      tcUrl.cell_value_factory = Proc.new do |e|
        #p e.value.value
        if e.value.value.is_a?(TreeWorkspace)
          e.value.value
        else
          SimpleStringProperty.new(e.value.value)
        end
      end
      tcUrl.cell_factory = Proc.new do |tc|
        WorkspaceCellFactory.new
      end
      col << tcUrl

      tcLastAcc = TreeTableColumn.new("Last Access")
      
      tcLastAcc.pref_width = 180.0
      tcLastAcc.max_width = 180.0
      tcLastAcc.min_width = 180.0

      col << tcLastAcc


      @trtblWorkspace.setRoot(@rootNode)
      @trtblWorkspace.columns.add_all(col)
      @trtblWorkspace.setShowRoot(true)


      #@trtblWorkspace.columns.clear
      @trtblWorkspace.column_resize_policy = javafx.scene.control.TreeTableView::CONSTRAINED_RESIZE_POLICY

      #colUrl = TableColumn.new("Path")
      #colUrl.cell_value_factory = Proc.new do |p|
      #  SimpleStringProperty.new(p.value.path)
      #end

      #colAccess = TableColumn.new("Last Access")
      #colAccess.cell_value_factory = Proc.new do |p|
      #  SimpleStringProperty.new(p.value.last_access)
      #end

      #colAccess.pref_width = 180.0
      #colAccess.max_width = colAccess.pref_width
      #colAccess.min_width = colAccess.pref_width

      #@trtblWorkspace.columns.add_all([colUrl, colAccess])

      #@trtblWorkspace.selection_model.selection_mode = javafx.scene.control.SelectionMode::SINGLE

      #@trtblWorkspace.selection_model.selected_items.add_listener do |evt|
      @trtblWorkspace.selection_model.selected_item_property.add_listener do |obs, oldV, newV|
        #puts "old value : #{oldV} / new value : #{newV}"
        if not_empty?(newV)
          
          if newV.value.is_a?(TreeWorkspace) and not_empty?(newV.value.workspace)

            if File.exist?(newV.value.workspace.path)
              # Here shall set a global reference to the selected workspace @selWs
              @selWs = Gvcs::Workspace.new(Global.instance.vcs, newV.value.workspace.path) 

              refresh_details
              show_details
            else
              show_landing
              prompt_error("Workspace '#{newV.value.workspace.path}' does not exist anymore.\nPlease remove it from workspace.")
            end

          else
            show_landing
          end
        else
          show_landing
        end
      end

      # project filter
      @cmbWorkspaceProjectFilter.value_property.add_listener(Proc.new do |ov, oldV, newV|
        # Javafx combobox not allow changing of internal value while it is updated
        # if not enclosed in the Platform.run_later() 
        # java.lang.IndexOutOfBoundsException shall be thrown
        Platform.run_later do
         
          @projectFilter = newV

          if not_empty?(newV)

            # here shall change the listing of the project
            refresh_workspace_list 

          end
        end
      end)

      refresh_workspace_list

    end

    def trtblWorkspace_onMouseClicked(evt)
      if evt.button == javafx.scene.input.MouseButton::SECONDARY
        # right click on item
        trtblWorkspace_ctxmnu.show(@trtblWorkspace, evt.screen_x, evt.screen_y)
      #elsif evt.button == javafx.scene.input.MouseButton::PRIMARY and evt.click_count == 2
      #  # double click on item - diff file
      #  sel = @tblChanges.selection_model.selected_items
      #  if sel.length > 0
      #    sel.each do |s|
      #      st, res = @selWs.diff_file(s.path)
      #      if st

      #        show_content_win("Diff Output", "Diff Result - #{s.path}", res)

      #      else
      #        set_err_gmsg("Diff for '#{s.path}' failed. [#{res}]")
      #      end

      #    end
      #  end

      end

    end

    # hooked to button Add
    def workspace_add(evt)

      path = @txtWorkspacePath.text
      if not_empty?(path)

        db = Global.instance.storage

        if not File.exist?(path)
          prompt_error("Given path '#{path}' does not exist. Please make sure it is a valid path.","Given Path Invalid",main_stage)
        elsif db.is_workspace_registered?(path)
          prompt_info("Given path '#{path}' already exist in the list.", "Path Already Exist", main_stage)
        else

          add_workspace(path)
          set_success_gmsg("Workspace '#{path}' added to list")

        end # if given path not exist

      else
        prompt_error "Please provide a folder path for Add operation", "Empty Path", main_stage
      end
      
    end

    def trtbleWorkspace_keyreleased(evt)
      if evt.code == javafx.scene.input.KeyCode::DELETE
        sel = @trtblWorkspace.selection_model.selected_item
        remove_workspace(sel)
      end 
    end

    def trtblWorkspace_dnd_dropped(evt)
      dnd_dropped(evt)
      evt.drop_completed = true
    end

    def trtblWorkspace_dnd_over(evt)
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
      db = Global.instance.storage(true)

      @rootNode.children.clear

      log_debug "#{db.workspaces.length} project(s) found"

      if db.workspaces.length > 0

        db.workspaces.keys.sort.each do |k|

          if not_empty?(@projectFilter) and @projectFilter != ALL_PROJ_FILTER
            next if k != @projectFilter
          end

          tws = TreeWorkspace.new(k,nil)
          pTi = TreeItem.new(tws)
          db.workspaces[k].each do |ws|
            ctws = TreeWorkspace.new(k,ws)
            pTi.children.add(TreeItem.new(ctws))
          end

          @rootNode.children.add(pTi)
        end

        @cmbWorkspaceProjectFilter.items.clear
        pf = [ALL_PROJ_FILTER]
        pf.concat(db.parent.sort)
        @cmbWorkspaceProjectFilter.items.add_all(pf)

        # this is so far most acceptable version 
        # if set value will trigger the listener above that shall trigger this method again
        # become vicious cycle
        @cmbWorkspaceProjectFilter.prompt_text = @projectFilter if not_empty?(@projectFilter)

        #show_details
      else
        show_landing
      end

      @selWs = nil

    end
    
    def show_details
      @pnlLanding.visible = false
      @tabPnlDetails.visible = true
    end

    def show_landing
      @pnlLanding.visible = true
      @tabPnlDetails.visible = false
    end

    #def workspace_key_released(evt)
    #  if evt.code == javafx.scene.input.KeyCode::DELETE
    #    sel = @trtblWorkspace.selection_model.selected_items.to_a
    #    if sel.length > 0
    #      s = sel.first.path
    #      res = fx_alert_confirmation("Delete workspace '#{s}' from system?\nThis won't affect physical file.", nil, "Remove Path from Management?", main_stage)
    #      if res == :ok
    #        Global.instance.storage.remove_workspace(s)
    #        Global.instance.storage.store
    #        refresh_workspace_list
    #        refresh_details
    #        log_debug "Workspace '#{s}' removed from management"
    #        set_info_gmsg("Workspace '#{s}' removed from management")
    #      else
    #        set_err_gmsg("Workspace delete operation aborted")
    #      end
    #    end

    #  end 
    #end

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

      ws.each do |w|
        log_debug "Adding workspace '#{w}'"
        add_workspace(w)
        set_success_gmsg("Workspace '#{w}' added to list")
      end 

      failed = { }
      nws.each do |w|
        log_debug "Adding non workspace '#{w}'"
        st, res = vcs.init(w)  
        if st
          add_workspace(w)
          set_success_gmsg("Non-workspace '#{w}' added to list")
        else
          failed[w] = res
        end
      end

      raise_event(Listener::Event[:workspace_added])

    end # dnd_dropped

    def add_workspace(path)
      
      raise_if_empty?(path, "Path cannot be empty in add workspace operation", GvcsFxException)

      db = Global.instance.storage
      awStage = javafx.stage.Stage.new
      dlg = AddWorkspaceController.load_into(awStage)
      # load existing projects into the combobox
      if db.parent.length > 0
        db.parent.each do |pa|
          dlg.add_option(pa)
        end
      else
        dlg.add_option(LEAF_PROJ_DESC)
      end

      # set the given path
      dlg.path = path
      awStage.title = "Add Workspace"
      awStage.init_owner(main_stage)

      awStage.showAndWait

      res = dlg.result

      if not_empty?(res)

        projName = nil
        if not is_empty?(res[0])
          if res[0] == AddWorkspaceController::ADDPROJ_KEY
            if is_empty?(res[1])
              prompt_error("Project name is required. Please try again")
            else
              projName = res[1]
            end
          else
            projName = res[0]
          end

        else
          projName = LEAF_PROJ_DESC
        end

        if not_empty?(projName)

          vcs = Gvcs::Vcs.new
          ds = Global.instance.storage

          tws = Gvcs::Workspace.new(vcs, path)
          vcs.init(path) if not tws.is_workspace?
          ds.add_workspace(projName,path)
          ds.store
          refresh_workspace_list
          @txtWorkspacePath.clear

        end

      end
     
    end # add_workspace

    def remove_workspace(sel)
    
      if not_empty?(sel)
        txt = sel.value
        db = Global.instance.storage

        if txt.is_a?(TreeWorkspace)

          if not_empty?(txt.workspace) 

            if db.is_workspace_registered?(txt.workspace.path)
              # leaf
              s = txt.workspace.path
              res = fx_alert_confirmation("Delete workspace '#{s}' from system?\nThis won't affect physical file.", nil, "Remove Path from Management?", main_stage)
              if res == :ok
                db.remove_workspace(s)
                db.store
                set_success_gmsg("Workspace '#{s}' removed from management")
                refresh_workspace_list
              end
            end

          else
            # project
            if db.is_project_registered?(txt.project) and db.is_project_empty?(txt.project)
              res = fx_alert_confirmation("Remove project '#{txt.project}' from the list?", nil, "Confirmation to Remove Project", main_stage)
              if res == :ok
                db.delete_project(txt.project)
                db.store
                set_success_gmsg("Project '#{txt.project}' removed from management")
                refresh_workspace_list
              end
            end
          end
        end # txt.is_a?(TreeWorkspace)

      end

    end

    def trtblWorkspace_ctxmnu
      
      @ctxSel = @trtblWorkspace.selection_model.selected_item
      trtblWsCtxMenu = javafx.scene.control.ContextMenu.new

      if not_empty?(@ctxSel) and @ctxSel.value.is_a?(TreeWorkspace)

        db = Global.instance.storage
        tws = @ctxSel.value
        if not_empty?(tws.workspace)
          if db.is_workspace_registered?(tws.workspace.path)
            # 
            # leaf
            # 
            # delete menu item
            #
            delMnuItm = javafx.scene.control.MenuItem.new("Remove from management")
            delMnuItm.on_action do |evt|

              remove_workspace(@ctxSel)

            end
            trtblWsCtxMenu.items.add(delMnuItm)
            # 
            # end diff menu item
            #
          end
        else
          # project
          if db.is_project_empty?(tws.project)
            # 
            # delete menu item
            #
            delMnuItm = javafx.scene.control.MenuItem.new("Remove from management")
            delMnuItm.on_action do |evt|

              remove_workspace(@ctxSel)

            end
            trtblWsCtxMenu.items.add(delMnuItm)
            # 
            # end diff menu item
            #

          end

        end

      end
      
     
      trtblWsCtxMenu 
    end

  end
end
