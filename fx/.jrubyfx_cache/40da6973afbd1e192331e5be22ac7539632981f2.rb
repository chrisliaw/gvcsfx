# 06a5e392f36302e47cfb9581ea1d2e8b72dbde01 encoding: utf-8
# @@ 1

########################### DO NOT MODIFY THIS FILE ###########################
#       This file was automatically generated by JRubyFX-fxmlloader on        #
# 2020-10-17 23:05:29 +0800 for /mnt/Vault/08.Dev/01.Workspaces/gvcs_fx/fx/show_text.fxml
########################### DO NOT MODIFY THIS FILE ###########################

module JRubyFX
  module GeneratedAssets
    class AOT40da6973afbd1e192331e5be22ac7539632981f2
      include JRubyFX
          def __build_via_jit(__local_fxml_controller, __local_namespace, __local_jruby_ext)
      __local_fx_id_setter = lambda do |name, __i|
        __local_namespace[name] = __i
        __local_fxml_controller.instance_variable_set(("@#{name}").to_sym, __i)
      end

build(Java::JavafxSceneLayout::VBox) do
 __local_jruby_ext[:on_root_set].call(self) if __local_jruby_ext[:on_root_set]
 getChildren.add(build(Java::JavafxSceneControl::Label) do
  setId("lblHeader")
  __local_fx_id_setter.call("lblHeader", self)
  setFont(build(FxmlBuilderBuilder, {"name"=>"System Bold", "size"=>"13.0"}, Java::JavafxSceneText::Font) do
  end)
  setText("Diff Result")
 end)
 getChildren.add(build(Java::JavafxSceneControl::TextArea) do
  setId("txtContent")
  __local_fx_id_setter.call("txtContent", self)
  Java::JavafxSceneLayout::VBox.setMargin(self, build(FxmlBuilderBuilder, {"bottom"=>"5.0", "top"=>"5.0"}, Java::JavafxGeometry::Insets) do
  end)
  setEditable(false)
  setMaxHeight(1.7976931348623157e+308)
  setMaxWidth(1.7976931348623157e+308)
  setMinHeight(280.0)
  setMinWidth(-Infinity)
  setWrapText(true)
  Java::JavafxSceneLayout::VBox.setVgrow(self, Java::javafx::scene::layout::Priority::ALWAYS)
 end)
 getChildren.add(build(Java::JavafxSceneLayout::HBox) do
  getChildren.add(build(Java::JavafxSceneControl::Button) do
   setId("butClose")
   __local_fx_id_setter.call("butClose", self)
   setMaxWidth(80.0)
   setMinWidth(80.0)
   setMnemonicParsing(false)
   setPrefWidth(80.0)
   setText("Close")
   setOnAction(EventHandlerWrapper.new(__local_fxml_controller, "win_close"))
  end)
  setAlignment(Java::javafx::geometry::Pos::CENTER_RIGHT)
  setMaxHeight(38.0)
  setMaxWidth(1.7976931348623157e+308)
  setMinHeight(38.0)
  setPrefHeight(38.0)
  Java::JavafxSceneLayout::VBox.setVgrow(self, Java::javafx::scene::layout::Priority::ALWAYS)
 end)
 setPadding(build(FxmlBuilderBuilder, {"bottom"=>"5.0", "left"=>"5.0", "right"=>"5.0", "top"=>"5.0"}, Java::JavafxGeometry::Insets) do
 end)
 setMaxHeight(-Infinity)
 setMaxWidth(-Infinity)
 setMinHeight(-Infinity)
 setMinWidth(-Infinity)
 setPrefHeight(353.0)
 setPrefWidth(600.0)
end
    end

      def hash
        "06a5e392f36302e47cfb9581ea1d2e8b72dbde01"
      end
      def compiled?
        true
      end
    end
  end
end