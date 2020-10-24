

module GvcsFx
  module TabTags

    class VCSTag
      include Antrapol::ToolRack::ExceptionUtils
      attr_accessor :key, :name, :date, :author, :subject
      def formatted_date
        if not_empty?(@date)
          dt = DateTime.strptime(@date,"%a %b %d %H:%M:%S %Y %z")
          dt.strftime("%d.%b.%Y (%a) %H:%M %z")
        else
          ""
        end
      end

      def to_s
        "#{@name} [#{formatted_date} by #{@author}]"
      end
    end

    def init_tab_tags

      @lstTags.add_event_handler(javafx.scene.input.MouseEvent::MOUSE_CLICKED, Proc.new do |evt|
        #if evt.button == javafx.scene.input.MouseButton::SECONDARY
        #  # right click on item
        #  branches_ctxmenu.show(@lstBranches, evt.screen_x, evt.screen_y)
        if evt.button == javafx.scene.input.MouseButton::PRIMARY and evt.click_count == 2
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

        end

        @lstTags.items.add_all(dat)
      end

      @txtNewTagName.clear
       
    end # refresh_tab_tags

    def create_tag(evt)
      tn = @txtNewTagName.text
      if is_empty?(tn)
        fx_alert_error("Tag name cannot be empty","Empty Tag Name", main_stage)
      else

        # annonated tag
        tns = tn.split('@')
        tag = nil
        msg = nil 
        if tns.length > 1
          tag = tns.first.strip
          msg = tns[1].strip
        else
          tag = tns.first.strip
        end

        st, res = @selWs.create_tag(tag,msg)
        if st
          fx_alert_info("New tag '#{tag}' successfully created.","New Tag Created",main_stage)
          refresh_tab_tags
        else
          fx_alert_error(res.strip, "New Tag Creation Failed", main_stage)
        end
      end
    end # create_tag

    def new_tag_keypressed(evt)
      if evt.code == javafx.scene.input.KeyCode::ENTER
        create_tag(nil)
      end
    end

  end
end
