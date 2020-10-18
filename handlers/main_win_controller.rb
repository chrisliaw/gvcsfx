
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

require_relative "notifier"
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

    include GvcsFx::Notifier
    include GvcsFx::EventHandler


    def initialize
      # sequence here is important
      install_handler
      init_tblWorkspace
      init_tab_state
      init_tab_logs
      init_tab_ignore_rules

      init_tab_repos

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

      if evt.target.text == "State"
        refresh_tab_state
        @shownTab = :state
      elsif evt.target.text == "Logs"
        refresh_tab_logs
        @shownTab = :logs
      elsif evt.target.text == "Ignore Rules"
        refresh_tab_ignore_rules
        @shownTab = :ignoreRules
      elsif evt.target.text == "Branches"
        refresh_tab_branches
        @shownTab = :branches
      elsif evt.target.text == "Tags"
        refresh_tab_tags
        @shownTab = :tags
      elsif evt.target.text == "Repository"
        refresh_tab_repos
        @shownTab = :repos
      end
    end

    def refresh_details

      case @shownTab
      when :state
        refresh_tab_state
      when :logs
        refresh_tab_logs
      when :ignoreRules
        refresh_tab_ignore_rules
      when :branches
        refresh_tab_branches
      when :tags
        refresh_tab_tags
      when :repos
        refresh_tab_repos
      end
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

  end
end
