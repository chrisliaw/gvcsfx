

module GvcsFx
  module EventHandler

    def install_handler
      handle_workspace_add
      handle_workspace_selected
    end

    def handle_workspace_add

      register(Notifier::Event[:workspace_added], Proc.new do |opts|

        # change display from landing to details
        show_details
        refresh_workspace_list

      end)

    end

    def handle_workspace_selected
      register(Notifier::Event[:workspace_selected], Proc.new do |opts|

        refresh_details

        #case @shownTab
        #when :state
        #  refresh_tab_state 
        #when :logs
        #  refresh_tab_logs
        #when :ignoreRules
        #  refresh_tab_ignore_rules
        #end

      end)
    end

  end
end
