
require 'jrubyfx'

require_relative "../lib/version"

fxml_root File.join(File.dirname(__FILE__),"..","fx")

require_relative '../handlers/main_win_controller'
require_relative '../handlers/tray'
require_relative '../handlers/float_win_controller'

# fxml_root first param = path when it is not in jar
# 2nd param = path when it is in jar
fxml_root File.join(File.dirname(__FILE__),"..",'fx'), 'gvcsfx/fx'

module GvcsFx
  class MainWin < JRubyFX::Application
    include GvcsFx::Tray

    attr_reader :stage
    def start(stage)
      
      @stage = stage
      #@stage.always_on_top = true
      #@stage.init_style = javafx.stage.StageStyle::UNDECORATED
      #javafx.application.Platform.implicit_exit = false

      # temporary disable for direct testing
      #with(stage, title: "G-VCS Float") do
      #  fxml FloatWinController
      #  show
      #end

      # this works!
      # But no in jar setting
      MainWinController.load_into(@stage)
      # This also works!
      # But also no in jar setting...
      # but this is more promising then the previous setup
      #MainWinController.load_into(@stage, { filename: "main.fxml" })
      @stage.show

      # this is correct can show tray 
      # but hide/show javafx stage doesn't work
      #javax.swing.SwingUtilities.invokeLater do
      #  start_tray(self)
      #end

    end # start

    def show_stage
      javafx.application.Platform.run_later do
        puts "insite run_later #{@stage}"
        if not @stage.nil?
          @stage.show
          @stage.toFront
        end
      end
    end

    def hide_stage
      javafx.application.Platform.run_later do
        @stage.hide
      end
    end

  end
end

GvcsFx::MainWin.launch

#if $0 == __FILE__
  #puts "Launching"

#GvcsFx::MainWin.launch
  ## put swing code in its own event loop or the right click menu and the icon itself won't show 
  #event_thread = nil
  #javax.swing.SwingUtilities.invokeAndWait { event_thread = java.lang.Thread.currentThread }
  #event_thread.join
#end

