


require 'jrubyfx'

# manually create the class

fxml_root File.join(File.dirname(__FILE__),"fx")

class Main
  include JRubyFX::Controller
  fxml "main.fxml"
end

class Main2
  include JRubyFX::Controller
end

class FloatWin
  include JRubyFX::Controller
  fxml "float.fxml"

  def show_context_menu(evt)
    init_ctxmenu.show(@imgFloat, evt.screen_x, evt.screen_y) 
  end


  private
  def init_ctxmenu

    if @ctx.nil?

      @ctx = ContextMenu.new
      mnuItems = []
      @mnuMain = MenuItem.new("G-VCS")
      @mnuMain.on_action do |evt|
        #ctrl = MainWinController.new
        #mainWin = JRubyFX::Controller.get_fxml_loader("main.fxml",ctrl)
        #root = mainWin.load

        stage = javafx.stage.Stage.new
        stage.title = "G-VCS"
        #stage.initModality(javafx.stage.Modality::WINDOW_MODAL)
        #stage.initOwner(@imgFloat.scene.window)
        ctrl = Main.load_into(stage)
        #ctrl = FloatWin.load_into(stage)
        #stage.scene = javafx.scene.Scene.new(root)
        
        stage.show
      end
      mnuItems << @mnuMain

      @mnuExit = MenuItem.new("Exit")
      @mnuExit.on_action do |evt|
        @imgFloat.scene.window.close 
      end
      mnuItems << @mnuExit

      @ctx.items.add_all(mnuItems)

    end

    @ctx
  end



end

class MainApp < JRubyFX::Application
  def start(stage)
    with(stage) do
      fxml FloatWin
      show
    end
  end
end

MainApp.launch


