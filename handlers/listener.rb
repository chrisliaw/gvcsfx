

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
