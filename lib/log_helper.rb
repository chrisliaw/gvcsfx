
require_relative 'global'

module GvcsFx
  module LogHelper

    def log_debug(msg, tag = "")
      if tag.nil? or tag.empty?
        Global.instance.logger.debug msg
      else
        Global.instance.logger.tdebug tag, msg
      end
    end

    def log_error(msg, tag = "")
      if tag.nil? or tag.empty?
        Global.instance.logger.error msg
      else
        Global.instance.logger.terror tag, msg
      end
    end

  end
end
