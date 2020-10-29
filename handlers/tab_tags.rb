

module GvcsFx
  module TabTags

    class VCSTag
      include Antrapol::ToolRack::ExceptionUtils
      attr_accessor :key, :name, :date, :author, :subject
      def formatted_date
        if not_empty?(@date)
          dt = rdate
          dt.strftime("%d.%b.%Y (%a) %H:%M %z")
        else
          ""
        end
      end

      # for sorting
      def rdate
        DateTime.strptime(@date,"%a %b %d %H:%M:%S %Y %z")
      end

      def to_s
        "#{@name} [#{formatted_date} by #{@author}]"
      end
    end

    def init_tab_tags
 
      @lstTags.selection_model.selection_mode = javafx.scene.control.SelectionMode::SINGLE
 
      @lstTags.add_event_handler(javafx.scene.input.MouseEvent::MOUSE_CLICKED, Proc.new do |evt|
        if evt.button == javafx.scene.input.MouseButton::SECONDARY
        #  # right click on item
          tags_ctxmenu.show(@lstTags, evt.screen_x, evt.screen_y)
        elsif evt.button == javafx.scene.input.MouseButton::PRIMARY and evt.click_count == 2
          # double click on item - view file
          sel = @lstTags.selection_model.selected_items
          if sel.length > 0
            s = sel.first
            st, res = @selWs.show_tag_detail(s.name)
            if st
              show_content_win("Tag Detail","Tag Detail", res)
            else
              prompt_error("Failed to load tag detail for tag '#{s}'. Error was : #{res}")
            end
          end

        end
      end)

    end

    def refresh_tab_tags

      @lstTags.items.clear

      dat = []
      st, res = @selWs.all_tags
      if st and not_empty?(res)
       
        res.each_line do |e|

          st2,res2 = @selWs.tag_info(e.strip)
          if st2

            res2.each_line do |r|
              rr = r.split("|")
              # extremely unreliable that depending on default
              # format in tag_info
              if rr.length == 4
                @rec = rr
                break
              else
                next
              end
            end

            # default format = %H|%ad|%an|%s 
            if not_empty?(@rec)
              vt = VCSTag.new
              vt.name = e.strip
              vt.key = @rec[0]
              vt.date = @rec[1]
              vt.author = @rec[2]
              vt.subject = @rec[3]
              #vt.name = e[0]
              #vt.date = e[1]
              #vt.author = e[2]
              #vt.subject = e[3]
              dat << vt
            end
          end

        end # tag info line

        # sort 
        dat = dat.sort do |a,b|
          case 
          when a.rdate < b.rdate
            1
          when a.rdate > b.rdate
            -1
          else
            a.rdate <=> b.rdate
          end
        end

        @lstTags.items.add_all(dat)
      end

      @txtNewTagName.clear
      @txtNewTagNote.clear
       
    end # refresh_tab_tags

    def create_tag(evt)
      tn = @txtNewTagName.text
      if is_empty?(tn)
        fx_alert_error("Tag name cannot be empty","Empty Tag Name", main_stage)
      else
        msg = @txtNewTagNote.text
        tn = tn.gsub(" ","-")
        st, res = @selWs.create_tag(tn,msg)
        if st
          set_success_gmsg("New tag '#{tn}' successfully created.")
          refresh_tab_tags
        else
          prompt_error(res.strip, "New Tag Creation Failed", main_stage)
        end
      end
    end # create_tag

    def new_tag_keypressed(evt)
      if evt.code == javafx.scene.input.KeyCode::ENTER
        create_tag(nil)
      end
    end

    def lstTags_keypressed(evt)
      if evt.code == javafx.scene.input.KeyCode::DELETE
        selTag = @lstTags.selection_model.selected_item
        if not selTag.nil?
          res = fx_alert_confirmation("Remove tag '#{selTag.name}'?", nil, "Confirmation to Remove Tag", main_stage)
          if res == :ok
            st, res = @selWs.delete_tag(selTag.name)

            if st
              set_success_gmsg("Tag '#{selTag.name}' successfully deleted.")
              refresh_tab_tags
            else
              prompt_error("Failed to delete tag '#{selTag.name}'. Error was : #{res}")
            end

          end          
        end
      end      
      #@selTag = @lstTags.selection_model.selected_item
    end

    def tagnote_keypressed(evt)
      if evt.code == javafx.scene.input.KeyCode::ENTER
        create_tag(nil)
      end
    end

    def tags_ctxmenu

      selTag = @lstTags.selection_model.selected_item

      tagsCtxMenu = javafx.scene.control.ContextMenu.new

      if not_empty?(selTag)

        coMnuItm = javafx.scene.control.MenuItem.new("Checkout to new branch")
        coMnuItm.on_action do |evt|

          st, name = fx_alert_input("Check out to a branch","Check out tag '#{selTag.name}' into new branch", "New Branch Name *")
          if st
            if not_empty?(name)
              sst, res = @selWs.checkout_tag(selTag.name, name)
              if sst
                set_success_gmsg(res)
                refresh_tab_tags
              else
                prompt_error("Failed to checkout tag '#{selTag.name}' to new branch '#{name}'. Error was : #{res}")
              end 
            else
              prompt_error("Please provide a branch name")
            end
          end

        end  # on_action do .. end

        tagsCtxMenu.items.add(coMnuItm)

      end

      tagsCtxMenu
      
    end

  end
end
