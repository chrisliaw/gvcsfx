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


require_relative 'fx_alert'

module GvcsFx
  
  class CmbOption
    attr_accessor :key, :string
    def initialize(key, str)
      @key = key
      @string = str
    end

    def to_s
      "#{@key} - #{@string}"
    end
  end
  
  
  class StashSelectController
    include JRubyFX::Controller
    include Antrapol::ToolRack::ExceptionUtils
    include GvcsFx::FxAlert

    fxml "stash_select.fxml"

    attr_reader :result

    def initialize
      @result = []
    end

    def options=(val)
      if not_empty?(val) 
        if val.is_a?(Array)
          @cmbOptions.items.add_all(val)
        elsif val.is_a?(Hash)
          dat = []
          val.each do |k,v|
            dat << CmbOption.new(k,v[1].strip)
          end
          @cmbOptions.items.add_all(dat)
        else
          @cmbOptions.items.add(val)
        end
      end
    end

    def win_close(evt)
      @result << false
      @butCancel.scene.window.close
    end

    def butOk_onAction(evt)
      br = @txtNewBranch.text
      sel = @cmbOptions.selection_model.selected_item
      if not_empty?(br) and not_empty?(sel)
        @result << true
        @result << sel 
        @result << br

        @butCancel.scene.window.close
      elsif is_empty?(sel)
        fx_alert_error("Stash selection cannot be empty. Please try again", "Empty Stash Selection", @butCancel.scene.window)
      elsif is_empty?(br)
        fx_alert_error("Branch name cannot be empty. Please try again", "Empty Branch Name", @butCancel.scene.window)
      end
    end

  end
end
