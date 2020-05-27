require 'ua_parser/result'

module UAParser
  def self.parse(user_agent)
    Result.new(Source.context.call("parse", user_agent))
  end

  module Source
    def self.bundled_path
      File.expand_path("../../../vendor/ua-parser.min.js", __FILE__)
    end

    PARSE_FUNCTION_SOURCE = <<-JS
      function parse(user_agent) {
        var parser = new UAParser();
        parser.setUA(user_agent);
        return parser.getResult();
      }
    JS

    def self.path
      @path ||= if File.exists?(ENV['UA_PARSER_SOURCE_PATH'])
                  ENV['UA_PARSER_SOURCE_PATH']
                else
                  bundled_path
                end
    end

    def self.contents
      @contents ||= File.read(path) + PARSE_FUNCTION_SOURCE
    end

    def self.version
      @version ||= contents[/UAParser.js v(.*)/, 1]
    end

    def self.context
      @context ||= ExecJS.compile(contents)
    end
  end

end
