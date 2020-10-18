


module GvcsFx
  class ShowTextController
    include JRubyFX::Controller
    fxml "show_text.fxml"

    def set_title(str)
      @lblHeader.text = str
    end

    def set_content(cnt)
      @txtContent.text = cnt
    end

    def win_close
      @butClose.scene.window.close  
    end

  end
end
