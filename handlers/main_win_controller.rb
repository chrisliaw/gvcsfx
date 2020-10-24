
require 'toolrack'

require 'gvcs'
require 'git_cli'

require_relative 'fx_alert'

require_relative "workspace"
require_relative "tab_state"
require_relative "tab_files"
require_relative "tab_branches"
require_relative "tab_tags"
require_relative "tab_repos"
require_relative "tab_logs"
require_relative "tab_ignore_rules"

require_relative "listener"
require_relative "notification"
require_relative "event_handler"

require_relative '../lib/log_helper'

module GvcsFx
  class MainWinController
    include JRubyFX::Controller
    fxml "main.fxml"

    include Antrapol::ToolRack::ExceptionUtils
    include GvcsFx::LogHelper
    include GvcsFx::FxAlert

    include GvcsFx::Workspace
    include GvcsFx::TabState
    include GvcsFx::TabFiles
    include GvcsFx::TabBranches
    include GvcsFx::TabTags
    include GvcsFx::TabRepos
    include GvcsFx::TabLogs
    include GvcsFx::TabIgnoreRules

    include GvcsFx::Listener
    include GvcsFx::EventHandler

    include GvcsFx::Notification


    def initialize
      # sequence here is important
      install_handler
      init_tblWorkspace
      init_tab_state
      init_tab_logs
      init_tab_ignore_rules

      init_tab_repos
      init_tab_branches
      init_tab_tags

      show_landing
    end

    def winclose
      @butClose.scene.window.close
      #p @butClose.scene.window
      #@butClose.scene.window.hide
    end

    def main_stage
      if @mstage.nil?
        @mstage = @butClose.scene.window
      end
      @mstage
    end

    def workspace_tab_changed(evt)
      #p evt.methods.sort
      #p evt.source
      ##p evt.source.methods.sort
      #p evt.source.text
      #p evt.target
      ##p evt.target.methods.sort
      #p evt.target.text

      javafx.application.Platform.run_later do

        # only update whatever tab that is visible right now
        if evt.target.text == "State"
          refresh_tab_state
        elsif evt.target.text == "Logs"
          refresh_tab_logs
        elsif evt.target.text == "Ignore Rules"
          refresh_tab_ignore_rules
        elsif evt.target.text == "Branches"
          refresh_tab_branches
        elsif evt.target.text == "Tags"
          refresh_tab_tags
        elsif evt.target.text == "Repository"
          refresh_tab_repos
        end

        reset_gmsg
      end
    end

    # refresh the whole bottom tabs
    def refresh_details

      currTab = @tabPnlDetails.selection_model.selected_item
      case currTab.text
      when "State"
        refresh_tab_state
      when "Logs"
        refresh_tab_logs
      when "Ignore Rules"
        refresh_tab_ignore_rules
      when "Branches"
        refresh_tab_branches
      when "Tags"
        refresh_tab_tags
      when "Repository"
        refresh_tab_repos
      end

      reset_gmsg

      # refresh state
      # refresh branch
      # refresh tags
      # refresh log
      # refresh files
      # refresh repos 
    end

    def rescue_exception(&block)
      begin
        yield
      rescue Exception => ex
        raise GvcsFxException, ex
      end
    end

    def inside_jar?
      File.dirname(__FILE__)[0..3] == "uri:"
    end

    def show_content_win(stageTitle, dlgTitle, content)

      javafx.application.Platform.run_later do
        stage = javafx.stage.Stage.new
        stage.title = stageTitle
        stage.initModality(javafx.stage.Modality::WINDOW_MODAL)
        #stage.initOwner(main_stage)
        dlg = ShowTextController.load_into(stage)
        dlg.set_title(dlgTitle)
        dlg.set_content(content)
        stage.showAndWait

      end # run_later

    end

  end
end
