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


require 'tlogger'
require 'singleton'

require 'gvcs'
require 'git_cli'

require_relative 'store'

module GvcsFx
  class Global
    include Singleton

    attr_reader :logger
    def initialize
      @logger = Tlogger.new
    end

    def storage(reload = true)
      if @store.nil? or reload
        @store = GvcsFx::DataStore::DefaultDataStore.load
      end

      @store
    end

    def vcs
      if @vcs.nil?
        @vcs = Gvcs::Vcs.new
      end

      @vcs
    end
  end

  class GvcsFxException < StandardError; end

  GVCSFX_STORE_ROOT = File.join(Dir.home,".gvcsfx")

end
