
java_import javafx.scene.control.Alert

module GvcsFx
  module FxAlert

    def fx_alert_info(msg, title = "Information", owner = nil)
      dlg = Alert.new(Alert::AlertType::INFORMATION)
      #dlg.header_text = msg
      dlg.title = title
      lbl = javafx.scene.control.Label.new(msg)
      lbl.wrap_text = true
      dlg.dialog_pane.content = lbl
      dlg.header_text = nil
      #dlg.content_text = msg
      dlg.init_modality(javafx.stage.Modality::WINDOW_MODAL)
      dlg.init_owner(owner) if not owner.nil?
      dlg.show_and_wait
    end

    def fx_alert_error(msg, title = "Error", owner = nil)
      dlg = Alert.new(Alert::AlertType::ERROR)
      #dlg.header_text = msg
      dlg.title = title
      lbl = javafx.scene.control.Label.new(msg)
      lbl.wrap_text = true
      dlg.dialog_pane.content = lbl
      dlg.header_text = nil
      dlg.init_modality(javafx.stage.Modality::WINDOW_MODAL)
      dlg.init_owner(owner) if not owner.nil?
      #dlg.init_style(javafx.stage.StageStyle::UTILITY)
      dlg.show_and_wait
    end

    def fx_alert_warning(msg, title = "Warning", owner = nil)
      dlg = Alert.new(Alert::AlertType::WARNING)
      #dlg.header_text = msg
      lbl = javafx.scene.control.Label.new(msg)
      lbl.wrap_text = true
      dlg.dialog_pane.content = lbl
      #dlg.content_text = msg
      dlg.title = title
      dlg.header_text = nil
      dlg.init_modality(javafx.stage.Modality::WINDOW_MODAL)
      dlg.init_owner(owner) if not owner.nil?
      dlg.show_and_wait
    end

    def fx_alert_confirmation(msg, header = nil, title = "Confirmation", owner = nil)

      dlg = javafx.scene.control.Alert.new(javafx.scene.control.Alert::AlertType::CONFIRMATION)
      dlg.init_modality(javafx.stage.Modality::WINDOW_MODAL)
      dlg.init_owner(owner) if not owner.nil?
      dlg.title = title
      dlg.header_text = header
      lbl = javafx.scene.control.Label.new(msg)
      lbl.wrap_text = true
      dlg.dialog_pane.content = lbl
      # this will make long text not shown as no wrapping is provided
      #dlg.content_text = msg

      #if not (opts[:custom_buttons].nil? or opts[:custom_buttons].empty?)
      #  cusBut = {  }
      #  opts.each do |key,act|
      #    par = [act[:name]]
      #    par << javafx.scene.control.ButtonBar.ButtonData::CANCEL_CLOSE if act[:is_cancel]
      #    cusBut[javafx.scene.control.ButtonType.new(*par)] = k

      #    dlg.getButtonTypes.setAll(*cusBut.keys)
      #  end
      #end

      res = dlg.show_and_wait

      #if not (opts[:custom_buttons].nil? or opts[:custom_buttons].empty?)
      #  sel = res.get
      #  key = cusBut[sel]
      #  key
      #else
        if res.get == javafx.scene.control.ButtonType::OK
          :ok
        else
          :cancel
        end
      #end
      
    end

  end
end
