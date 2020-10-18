

module GvcsFx
  module TabTags

    def init_tab_tags

    end

    def refresh_tab_tags
      @lstTags.items.clear

      st, res = @selWs.all_tags_with_date
      if st and not_empty?(res)
        dat = []
        res.each do |tag, date|
          dt = DateTime.strptime(date,"%Y-%m-%d %H:%M:%S %z")
          dat << "#{tag} - (#{dt.strftime("%d.%b.%Y %H:%M %z")})"
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
        st, res = @selWs.create_tag(tn)
        if st
          fx_alert_info("New tag '#{tn}' successfully created.","New Tag Created",main_stage)
          refresh_tab_tags
        else
          fx_alert_error(res.strip, "New Tag Creation Failed", main_stage)
        end
      end
    end # create_tag

  end
end
