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
