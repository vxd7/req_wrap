# frozen_string_literal: true

require 'optparse'

require 'req_wrap/generator/req'

module ReqWrap
  class Cli
    COMMAND_ALIASES = {
      'generate' => %w[generate g gen],
      'environment' => %w[environment e env]
    }.freeze

    def initialize
      @options = {}
    end

    def call(args)
      arguments = args.dup
      user_command = arguments.shift

      command = find_command(user_command)
      return send(command, arguments) if command

      puts common_options
      exit(1)
    end

    private

    def common_options
      OptionParser.new do |parser|
        parser.on('-h', '--help', 'Show help message') do
          puts parser
          exit
        end

        parser.separator('')
        parser.separator('')
      end
    end

    def generate_banner
      <<~BANNER
        Usage: req_wrap g [options...] <request_file>

        <request_file> can be either absolute path to filename or relative path.
        Ruby extension (.rb) is optional and will be added automatically.

      BANNER
    end

    def generate_examples
      <<~EXAMPLES
        Examples of invocation:
        - req_wrap g sample_req             # Create './sample_req.rb' request file
        - req_wrap g sample_req.rb          # Create './sample_req.rb' request file
        - req_wrap g requests/sample_req.rb # Create './requests/sample_req.rb' request file
      EXAMPLES
    end

    def generate(args)
      parser = OptionParser.new(generate_banner) do |p|
        # Dummy argument. Will be used when new request types are added
        #
        p.on('--http', 'Generate new dummy HTTP request (default)')

        p.separator('')
        p.separator(generate_examples)
      end

      parser.parse!(args)

      request_file = args.shift.strip
      raise ArgumentError, 'request_file is required' unless request_file

      Generator::Req.new(request_file).call
    end

    def environment_banner
      <<~BANNER
        Usage: req_wrap e [options...]

        Manage environment files used by request scripts
      BANNER
    end

    def environment_examples
      require 'req_wrap/environment'
      key_file_name = Environment::KEY_FILE

      <<~EXAMPLES
        Examples of invocation:
        - req_wrap e --gen-pass           # Generate password file for env variable files encryption ('#{key_file_name}')
        - req_wrap e --enc env_file.env   # Encrypt environment file env_file.env using generated password
        - E=env_file.env req_wrap e --enc # Encrypt environment file env_file.env using generated password
      EXAMPLES
    end

    def environment(args)
      parser = OptionParser.new(environment_banner) do |p|
        p.on('--gen-pass', 'Generate password file')
        p.on('--enc <env_file>', 'Encrypt environment file and write the result to env_file.enc file')
        p.on('--delete-original', 'Delete original environment file after encryption')

        p.separator('')
        p.separator(environment_examples)
      end

      parser.parse!(args)
    end

    def find_command(user_command)
      COMMAND_ALIASES.detect do |_command_name, command_aliases|
        command_aliases.include?(user_command)
      end&.first
    end
  end
end
