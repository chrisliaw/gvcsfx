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
      
    end # fx_alert_confirmation

    def fx_alert_input(title, header, content)
      dlg = javafx.scene.control.TextInputDialog.new
      dlg.title = title
      dlg.header_text = header
      dlg.content_text = content
      res = dlg.show_and_wait
      if res.is_present
        # there is some string in the text field
        [true, res.get]
      else
        [false, ""]
      end
    end

  end
end
