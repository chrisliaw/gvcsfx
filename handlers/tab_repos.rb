

module GvcsFx
  module TabRepos

    class GvcsFxRepository
      include javafx.beans.value.ObservableValue
      attr_reader :repos, :branch
      def initialize(repos,branch)
        @repos = repos
        @branch = branch
      end

      def addListener(list)
      end

      def removeListener(list)
      end

      def value
        self
      end
    end

    class URLTableCell < javafx.scene.control.TableCell
      def updateItem(itm, isEmpty)
        super
        if item.nil?
          setGraphic(nil)
        else
          repos = itm.repos
          br = itm.branch
          #st = []
          #st << repos.url
          #st << "Push to / Pull from current branch : #{br}"
          #lbl = javafx.scene.control.Label.new(st.join("\n"))
          lbl = javafx.scene.control.Label.new(repos.url)
          setGraphic(lbl)
        end
      end
    end

    def init_tab_repos

      @tblRepos.placeholder = javafx.scene.control.Label.new("No remote repository configured")

      @tblRepos.columns.clear
      @tblRepos.column_resize_policy = javafx.scene.control.TableView::CONSTRAINED_RESIZE_POLICY

      cols = []
      colName = TableColumn.new("Name")
      colName.cell_value_factory = Proc.new do |c|
        SimpleStringProperty.new(c.value.repos.name)
      end
      cols << colName
      
      colUrl = TableColumn.new("URL")
      colUrl.cell_value_factory = Proc.new do |c|
        c.value
      end
      colUrl.cell_factory = Proc.new do |tc|
        URLTableCell.new
      end
      cols << colUrl

      #@cmbRepoBranches = javafx.scene.control.ComboBox.new
      #colBranches = TableColumn.new("Branch")
      #colBranches.cell_factory = Proc.new do |tc|
      #  @tblCelReposBranch = ReposBranchTableCell.new
      #  @tblCelReposBranch
      #end
      #colBranches.cell_value_factory = Proc.new do |p|
      #  p.value.branches
      #end
      #colBranches.cell_value_factory = Proc.new do |p|
      #  SimpleStringProperty.new(p.value.url)
      #end
      #cols << colBranches

      @tblRepos.columns.add_all(cols)

      colName.pref_width = 180.0
      colName.max_width = 280.0
      colName.min_width = 160.0

      #colBranches.pref_width = 180.0
      #colBranches.max_width = 220.0
      #colBranches.min_width = 168.0

      @tblRepos.selection_model.selection_mode = javafx.scene.control.SelectionMode::SINGLE

      #@tblRepos.add_event_handler(javafx.scene.input.MouseEvent::MOUSE_CLICKED, Proc.new do |evt|
      #  if evt.button == javafx.scene.input.MouseButton::SECONDARY
      #    # right click on item
      #    changes_ctxmenu.show(@tblChanges, evt.screen_x, evt.screen_y)
      #  elsif evt.button == javafx.scene.input.MouseButton::PRIMARY and evt.click_count == 2
      #    # double click on item - view file
      #    sel = @tblChanges.selection_model.selected_items
      #    if sel.length > 0
      #      sel.each do |s|
      #        view_file(s.path)
      #      end
      #    end

      #  end
      #end)

    end

    def refresh_tab_repos

      @txtReposName.clear
      @txtReposUrl.clear

      st, @currBr = @selWs.current_branch
      @currBr = "<unknown>" if not st

      @lblReposMessage.text = "Operation push & pull always based on current branch [Current branch is '#{@currBr}'].\nIf you want to push / pull to different branch, change it at the 'Branches' tab before come here."

      refresh_repos_list      

    end

    def refresh_repos_list

      @tblRepos.items.clear

      st, res = @selWs.remote_config 
      if st
        rp = []
        res.each do |k,v|
          #repos = Gvcs::Repository.new(k,v) 
          repos = Gvcs::Repository.new(k,v)
          rp << GvcsFxRepository.new(repos,"")
          #st, br = @selWs.current_branch 
          #if st
          #  rp << GvcsFxRepository.new(repos,br) 
          #else
          #  rp << GvcsFxRepository.new(repos,"<unknown>") 
          #end
          #rp << repos
        end

        @tblRepos.items.add_all(rp)
        
      end
      
    end

    def repos_key_released(evt)

      if evt.code == javafx.scene.input.KeyCode::DELETE
        sel = @tblRepos.selection_model.selected_items.to_a
        if sel.length > 0
          nm = sel.first.repos.name
          pa = sel.first.repos.url
          res = fx_alert_confirmation("Delete Repository '#{nm} - #{pa}' from system?", nil, "Remove Repository?", main_stage)
          if res == :ok
            st, rres = @selWs.remove_remote(nm)
            if st
              refresh_repos_list
              log_debug "Remote repository '#{nm} - #{pa}' removed from workspace"
              set_success_gmsg("Remote repository '#{nm} - #{pa}' removed from workspace")
            else
              fx_alert_error(rres,"Remove Repository Exception",main_stage)
            end
          end
        end

      end 
      
    end

    def add_repository(evt)

      nm = @txtReposName.text
      pa = @txtReposUrl.text

      if is_empty?(nm)
        fx_alert_error("Repository name cannot be empty","Repository Name Empty",main_stage)
      elsif is_empty?(pa)
        fx_alert_error("Repository URL cannot be empty","Repository URL Empty",main_stage)
      else
        st, res = @selWs.add_remote(nm,pa)
        if st

          @txtReposName.clear
          @txtReposUrl.clear

          refresh_repos_list
        else
          fx_alert_error(res.strip, "Add Repository Exception", main_stage)
        end
      end

    end

    def txtReposUrl_key_released(evt)

      if evt.code == javafx.scene.input.KeyCode::ENTER
        add_repository(nil)
        evt.consume
      end 
      
    end

    def butRepositoryOpen_onAction(evt)
      dc = javafx.stage.DirectoryChooser.new 
      dc.title = "Select Local Repository"
      wsDir = dc.showDialog(main_stage)

      @txtReposUrl.text = wsDir.absolute_path
    end

    def repos_pull(evt)
      sel = @tblRepos.selection_model.selected_items.to_a
      if sel.length > 0
        selRepos = sel.first
        
        repos = selRepos.repos.name
        @selWs.add_repos(selRepos.repos)
        ret, msg = @selWs.pull(repos, @currBr)
        if ret
          set_success_gmsg(msg)
        else
          fx_alert_error(msg, "GVCS Repository Pull Exception", main_stage)
        end

      else
        fx_alert_error("No repository selected. Please select one repository to pull.", "No Repository Selected", main_stage)
      end
    end

    def repos_push(evt)
      sel = @tblRepos.selection_model.selected_items.to_a
      if sel.length > 0

        selRepos = sel.first
        withTag = @chkPushWithTag.isSelected
        
        repos = selRepos.repos.name
        @selWs.add_repos(selRepos.repos)
        if withTag
          ret, msg = @selWs.push_changes_with_tags(repos, @currBr)
        else
          ret, msg = @selWs.push_changes(repos, @currBr)
        end

        if ret
          set_success_gmsg(msg)
        else
          fx_alert_error(msg, "GVCS Repository Push Exception", main_stage)
        end

      else
        fx_alert_error("No repository selected. Please select one repository to push.", "No Repository Selected", main_stage)
      end
    end

  end
end
