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
  module Notification

    def prompt_error(str, title = "GVCS Error", stage = main_stage)
      set_err_gmsg(str)
      fx_alert_error(str, title, stage)
      log_error(str)
    end
    def prompt_info(str, title = "GVCS Info", stage = main_stage)
      set_info_gmsg(str)
      fx_alert_info(str, title, stage)
    end
    def prompt_warn(str, title = "GVCS Warning", stage = main_stage)
      set_warn_gmsg(str)
      fx_alert_warn(str, title, stage)
      log_warn(str)
    end

    def reset_gmsg
      @imgGmsg.image = nil
      @lblGlobalMsg.text = ""
    end

    def set_success_gmsg(str)
      set_gmsg(str, :success)
    end
    def set_info_gmsg(str)
      set_gmsg(str, :info)
    end
    def set_err_gmsg(str)
      set_gmsg(str,:err)
    end
    def set_warn_gmsg(str)
      set_gmsg(str, :warn)
    end

    private
    def set_gmsg(str, type = :info)
      case type
      when :err
        @imgGmsg.setImage(load_image(:err))
      when :warn
        @imgGmsg.setImage(load_image(:warn))
      when :success
        @imgGmsg.setImage(load_image(:success))
      else
        @imgGmsg.setImage(load_image(:info))
      end
      @lblGlobalMsg.text = str

    end  # set_gmsg

    def load_image(type)
      case type
      when :err
        if @errImg.nil?
          if inside_jar?
            @errImg = javafx.scene.image.Image.new(java.lang.Object.new.java_class.resource("/gvcsfx/res/cross.png").to_s)
          else
            @errImg = javafx.scene.image.Image.new("res/cross.png")
          end
        end
        @errImg
      when :warn
        if @warnImg.nil?
          if inside_jar?
            @warnImg = javafx.scene.image.Image.new(java.lang.Object.new.java_class.resource("/gvcsfx/res/warn.png").to_s)
          else
            @warnImg = javafx.scene.image.Image.new("res/warn.png")
          end
        end
        @warnImg
      when :success
        if @sucImg.nil?
          if inside_jar?
            @sucImg = javafx.scene.image.Image.new(java.lang.Object.new.java_class.resource("/gvcsfx/res/tick.png").to_s)
          else
            @sucImg = javafx.scene.image.Image.new("res/tick.png")
          end
        end
        @sucImg
      else
        if @infoImg.nil?
          if inside_jar?
            @infoImg = javafx.scene.image.Image.new(java.lang.Object.new.java_class.resource("/gvcsfx/res/world.png").to_s)
          else
            @infoImg = javafx.scene.image.Image.new("res/world.png")
          end
        end
        @infoImg
      end
    end # load_image


  end
end
