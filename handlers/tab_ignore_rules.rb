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
  module TabIgnoreRules

    def init_tab_ignore_rules
      @txtIgnoreRules.prompt_text = "No ignore rules defined"
    end

    def refresh_tab_ignore_rules
      @txtIgnoreRules.text = @selWs.ignore_rules  
    end

    def on_save_ignore_rules(evt)
      st,res = @selWs.update_ignore_rules(@txtIgnoreRules.text)   
      if st
        set_success_gmsg(res)
      else
        prompt_error(res,"Save Ignore Rules Error")
      end
    end

  end
end
