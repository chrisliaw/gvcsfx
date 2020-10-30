
java_import javafx.scene.control.ContextMenu

require_relative "main_win_controller"

module GvcsFx
  class FloatWinController
    include JRubyFX::Controller
    fxml "float.fxml"

    def initialize
    end


    def show_context_menu(evt)
      init_ctxmenu.show(@imgFloat, evt.screen_x, evt.screen_y) 
    end


    private
    def init_ctxmenu

      if @ctx.nil?

        @ctx = ContextMenu.new
        mnuItems = []
        @mnuMain = javafx.scene.control.MenuItem.new("G-VCS")
        @mnuMain.on_action do |evt|
         stage = javafx.stage.Stage.new
          stage.title = "G-VCS"
          #stage.initModality(javafx.stage.Modality::WINDOW_MODAL)
          #stage.initOwner(@imgFloat.scene.window)
          ctrl = MainWinController.load_into(stage)
          stage.show
        end
        mnuItems << @mnuMain

        @mnuExit = javafx.scene.control.MenuItem.new("Exit")
        @mnuExit.on_action do |evt|
          @imgFloat.scene.window.close 
        end
        mnuItems << @mnuExit

        @ctx.items.add_all(mnuItems)

      end

      @ctx
    end

  end
end
