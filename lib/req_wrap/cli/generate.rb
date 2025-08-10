# frozen_string_literal: true

require 'optparse'

require 'req_wrap/generator/req'

module ReqWrap
  class Cli
    class Generate
      def initialize
        @options = {}
      end

      def call(args)
        parser = OptionParser.new(banner) do |p|
          add_desc_option(p)

          p.separator('')
          p.separator(examples)
        end

        parser.parse!(args)
        return generate_request!(args) unless args.empty?

        puts parser
        exit(1)
      end

      private

      def generate_request!(args)
        request_file = args.shift.strip
        raise ArgumentError, 'request_file argument cannot be empty' if request_file.empty?

        Generator::Req.new(request_file, @options).call
      end

      def banner
        <<~BANNER
          Usage: req_wrap g [options...] <request_file>

          <request_file> can be either absolute path to filename or relative path.
          Ruby extension (.rb) is optional.

        BANNER
      end

      def examples
        <<~EXAMPLES
          Examples of invocation:
          - req_wrap g sample_req             # Create './sample_req.rb' request file
          - req_wrap g sample_req.rb          # Create './sample_req.rb' request file
          - req_wrap g requests/sample_req.rb # Create './requests/sample_req.rb' request file
        EXAMPLES
      end

      def add_desc_option(parser)
        option_desc = 'Add optional description to the generated request definition'

        parser.on('-d', '--desc [description]', option_desc) do |request_description|
          @options[:request_description] = request_description.strip
        end
      end
    end
  end
end
