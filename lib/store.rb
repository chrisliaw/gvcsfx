

require 'yaml'
require 'fileutils'

require_relative 'global'

module GvcsFx
  module DataStore

    class Workspace
      attr_accessor :path, :last_access, :parent
      def initialize(path, parent)
        @path = path
        @parent = parent
      end
    end

    class DefaultDataStore
    
      include Antrapol::ToolRack::ExceptionUtils

      FILENAME = "workspaces_tr.yml"
      DEFPATH = File.join(GvcsFx::GVCSFX_STORE_ROOT, FILENAME)

      attr_reader :workspaces
      attr_reader :parent, :paths, :wsList
      def initialize
        @workspaces = { }
        @wsRef = { }
        @paths = []
        @parent = []
      end

      def store(path = DEFPATH)
        if not (path.nil? or path.empty?)
          if not File.exist?(File.dirname(path))
            FileUtils.mkdir_p File.dirname(path)
          end

          @parent = @workspaces.keys.sort

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

            obj = YAML.load(@cont)
          rescue Exception => ex
            Global.instance.logger.error ex.message
            Global.instance.logger.error "Failed to load store from '#{path}'. Returning new instance."
            DefaultDataStore.new
          end
        else
          DefaultDataStore.new
        end
      end

      def new_project(proj)
        if not_empty?(proj)
          @workspaces[proj] = []
        end
      end

      def delete_project(proj)
        if not_empty?(proj) and @workspaces.keys.include?(proj)
          @workspaces.delete(proj)
          @parent.delete(proj)
        end
      end

      def is_project_registered?(proj)
        if not_empty?(proj)
          @workspaces.keys.include?(proj)
        end
      end

      def add_workspace(parent, path)
        raise GvcsFxException, "Parent cannot be empty" if parent.nil? or parent.empty?
        raise GvcsFxException, "Path cannot be empty" if path.nil? or path.empty?


        if not @paths.include?(path) 
          if not @workspaces.keys.include?(parent)
            @workspaces[parent] = []
          end

          ws = Workspace.new(path, parent)
          @workspaces[parent] << ws 
          # todo sort the array of parent... but the array contains object
          # custom sorter is required
          @paths << path
          @wsRef[path] = ws
        end
      end # add_workspace

      def remove_workspace(path)
        raise GvcsFxException, "Path cannot be empty" if path.nil? or path.empty?

        ws = @wsRef[path]
        @workspaces[ws.parent].delete(ws)
        @paths.delete(path)
        @wsRef.delete(path)

      end # remove_workspace

      def is_workspace_registered?(path)
        @paths.include?(path.strip)
      end # is workspace_registered?

      def is_project_empty?(proj)
        @workspaces[proj].length == 0
      end

    end # DefaultDataStore

  end # DataStore
end # GvcsFx
