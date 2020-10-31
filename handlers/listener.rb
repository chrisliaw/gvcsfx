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
  module Listener

    Event = {
      workspace_added: :workspace_added,
      workspace_selection_changed: :workspace_selection_changed
    }

    def register(event, proctal)
      if not is_event_listed?(event)
        event_listeners[event] = []
      end

      event_listeners[event] << proctal
    end

    def deregister(event,proctal)
      event_listeners[event].delete(proctal)
    end

    def raise_event(event, opts = { })
      event_listeners[event].each do |hdl|
        hdl.call(opts) 
      end
    end

    private
    def event_listeners
      if @eventListener.nil?
        @eventListener = { }
      end

      @eventListener
    end

    def is_event_listed?(evt)
      event_listeners.keys.include?(evt)
    end

  end
end
