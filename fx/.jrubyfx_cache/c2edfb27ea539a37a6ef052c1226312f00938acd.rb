# 1074b3ba8b3f61b9d159f2f3cf947dc1c9d52135 encoding: utf-8
# @@ 1

########################### DO NOT MODIFY THIS FILE ###########################
#       This file was automatically generated by JRubyFX-fxmlloader on        #
# 2020-10-16 16:49:50 +0800 for /mnt/Vault/08.Dev/01.Workspaces/gvcs_fx/fx/float.fxml
########################### DO NOT MODIFY THIS FILE ###########################

module JRubyFX
  module GeneratedAssets
    class AOTc2edfb27ea539a37a6ef052c1226312f00938acd
      include JRubyFX
          def __build_via_jit(__local_fxml_controller, __local_namespace, __local_jruby_ext)
      __local_fx_id_setter = lambda do |name, __i|
        __local_namespace[name] = __i
        __local_fxml_controller.instance_variable_set(("@#{name}").to_sym, __i)
      end

build(Java::JavafxSceneLayout::VBox) do
 __local_jruby_ext[:on_root_set].call(self) if __local_jruby_ext[:on_root_set]
 getChildren.add(build(Java::JavafxSceneImage::ImageView) do
  setId("imgFloat")
  __local_fx_id_setter.call("imgFloat", self)
  setFitHeight(88.0)
  setFitWidth(88.0)
  setPickOnBounds(true)
  setPreserveRatio(true)
  setOnContextMenuRequested(EventHandlerWrapper.new(__local_fxml_controller, "show_context_menu"))
  setOnDragDropped(EventHandlerWrapper.new(__local_fxml_controller, "float_dnd_drop"))
 end)
 setAlignment(Java::javafx::geometry::Pos::CENTER)
 setMaxHeight(-Infinity)
 setMaxWidth(-Infinity)
 setMinHeight(-Infinity)
 setMinWidth(-Infinity)
 setPrefHeight(88.0)
 setPrefWidth(88.0)
end
    end

      def hash
        "1074b3ba8b3f61b9d159f2f3cf947dc1c9d52135"
      end
      def compiled?
        true
      end
    end
  end
end
