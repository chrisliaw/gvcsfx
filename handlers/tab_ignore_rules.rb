

module GvcsFx
  module TabIgnoreRules

    def init_tab_ignore_rules
      @txtIgnoreRules.prompt_text = "No ignore rules defined"
    end

    def refresh_tab_ignore_rules
      @txtIgnoreRules.text = @selWs.ignore_rules  
    end

  end
end
