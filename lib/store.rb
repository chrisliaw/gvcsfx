

require 'yaml'
require 'fileutils'

require_relative 'global'

module GvcsFx
  module DataStore

    class Workspace
      attr_accessor :name, :path, :last_access
      def initialize(name, path)
        @name = name
        @path = path
      end
    end

    class DefaultDataStore
     
      FILENAME = "workspaces.yml"
      DEFPATH = File.join(GvcsFx::GVCSFX_STORE_ROOT, FILENAME)

      attr_reader :workspaces
      def initialize
        @workspaces = []
        @paths = []
      end

      def store(path = DEFPATH)
        if not (path.nil? or path.empty?)
          if not File.exist?(File.dirname(path))
            FileUtils.mkdir_p File.dirname(path)
          end

          File.open(path,"w") do |f|
            f.write YAML.dump(self)
          end
        end
      end

      def self.load(path = DEFPATH)
        if not (path.nil? or path.empty?)
          begin
            File.open(path,"r") do |f|
              @cont = f.read
            end

            YAML.load(@cont)
          rescue Exception => ex
            Global.instance.logger.error ex.message
            Global.instance.logger.error "Failed to load store from '#{path}'. Returning new instance."
            DefaultDataStore.new
          end
        else
          DefaultDataStore.new
        end
      end

      def add_workspace(name, path)
        #raise GvcsFxException, "Name cannot be empty" if name.nil? or name.empty?
        raise GvcsFxException, "Path cannot be empty" if path.nil? or path.empty?

        name = path if name.nil? or name.empty?

        if not @paths.include?(path) 
          @workspaces << Workspace.new(name, path)
          @paths << path
        end
      end

      def remove_workspace(path)
        raise GvcsFxException, "Path cannot be empty" if path.nil? or path.empty?

        @workspaces.each do |w|
          if w.path == path
            @workspaces.delete(w)
            @paths.delete(w)
            break
          end
        end

      end

    end # DefaultDataStore

  end # DataStore
end # GvcsFx
