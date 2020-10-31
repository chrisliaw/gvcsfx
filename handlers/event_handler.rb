# Copyright (C) 2020  Chris Liaw <chrisliaw@antrapol.com>
# Author: Chris Liaw <chrisliaw@antrapol.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.



module GvcsFx
  module EventHandler

    def install_handler
      handle_workspace_add
      handle_workspace_selection_changed
    end

    def handle_workspace_add

      register(Listener::Event[:workspace_added], Proc.new do |opts|

        # change display from landing to details
        # NO workspace selected yet so hold
        #show_details
        refresh_workspace_list

      end)

    end

    def handle_workspace_selection_changed
      register(Listener::Event[:workspace_selection_changed], Proc.new do |opts|
        
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
