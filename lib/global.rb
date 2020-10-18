
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

    def storage
      if @store.nil?
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
