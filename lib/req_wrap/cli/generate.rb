# frozen_string_literal: true

require 'optparse'

require 'req_wrap/generator/req'

module ReqWrap
  class Cli
    class Generate
      def call(args)
        parser = OptionParser.new(banner) do |p|
          # Dummy argument. Will be used when new request types are added
          #
          p.on('--http', 'Generate new dummy HTTP request (default)')

          p.separator('')
          p.separator(examples)
        end

        parser.parse!(args)

        request_file = args.shift.strip
        raise ArgumentError, 'request_file is required' unless request_file

        Generator::Req.new(request_file).call
      end

      private

      def banner
        <<~BANNER
          Usage: req_wrap g [options...] <request_file>

          <request_file> can be either absolute path to filename or relative path.
          Ruby extension (.rb) is optional and will be added automatically.

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
    end
  end
end
