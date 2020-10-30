
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
