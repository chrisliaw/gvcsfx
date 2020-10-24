

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
