# frozen_string_literal: true

require 'optparse'

require 'req_wrap/cli/environment'
require 'req_wrap/cli/generate'

module ReqWrap
  class Cli
    COMMAND_ALIASES = {
      'generate' => %w[generate g gen],
      'environment' => %w[environment e env]
    }.freeze

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

    def environment(args)
      Environment.new.call(args)
    end

    def generate(args)
      Generate.new.call(args)
    end

    def find_command(user_command)
      COMMAND_ALIASES.detect do |_command_name, command_aliases|
        command_aliases.include?(user_command)
      end&.first
    end
  end
end
