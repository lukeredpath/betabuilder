require 'restclient'

module Jekyll
  class UltravioletTag < Liquid::Block
    def initialize(tag_name, syntax, tokens)
      super
      @syntax = syntax.strip
    end
    
    def render(context)
      Ultraviolence.convert(super.join, @syntax)
    rescue StandardError => e
      "Ultraviolence: Could not render! (#{e})"
    end
  end
  
  module Ultraviolence
    API = "http://ultraviolence.heroku.com/api"
    
    def self.convert(text, syntax)
      RestClient.post("#{API}?syntax=#{syntax}&l=0", text).gsub(/mac_classic/, 'syntax')
    end
  end
end

Liquid::Template.register_tag('ultrahighlight', Jekyll::UltravioletTag)
