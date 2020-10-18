

module GvcsFx
  module TabRepos

    def init_tab_repos

      @tblRepos.placeholder = javafx.scene.control.Label.new("No remote repository configured")

      @tblRepos.columns.clear
      @tblRepos.column_resize_policy = javafx.scene.control.TableView::CONSTRAINED_RESIZE_POLICY

      cols = []
      colName = TableColumn.new("Name")
      colName.cell_value_factory = Proc.new do |p|
        SimpleStringProperty.new(p.value.name)
      end
      cols << colName
      
      colUrl = TableColumn.new("URL")
      colUrl.cell_value_factory = Proc.new do |p|
        SimpleStringProperty.new(p.value.url)
      end
      cols << colUrl

      @tblRepos.columns.add_all(cols)

      colName.pref_width = 180.0
      colName.max_width = 280.0
      colName.min_width = 160.0

      #@tblRepos.selection_model.selection_mode = javafx.scene.control.SelectionMode::MULTIPLE

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

      refresh_repos_list      

    end

    def refresh_repos_list

      @tblRepos.items.clear

      st, res = @selWs.remote_config 
      if st
        rp = []
        res.each do |k,v|
          repos = Gvcs::Repository.new(k,v) 
          rp << repos
        end

        @tblRepos.items.add_all(rp)
        
      end
      
    end

    def repos_key_released(evt)

      if evt.code == javafx.scene.input.KeyCode::DELETE
        sel = @tblRepos.selection_model.selected_items.to_a
        if sel.length > 0
          nm = sel.first.name
          pa = sel.first.url
          res = fx_alert_confirmation("Delete Repository '#{nm} - #{pa}' from system?", nil, "Remove Repository?", main_stage)
          if res == :ok
            st, rres = @selWs.remove_remote(nm)
            if st
              refresh_repos_list
              log_debug "Remote repository '#{nm} - #{pa}' removed from workspace"
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

    def repos_pull(evt)
    end

    def repos_push(evt)
    end

  end
end
