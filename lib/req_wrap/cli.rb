# frozen_string_literal: true

require 'optparse'

require 'req_wrap/cli/environment'
require 'req_wrap/cli/generate'

module ReqWrap
  class Cli
    COMMAND_ALIASES = {
      'generate' => %w[g gen],
      'environment' => %w[e env]
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
        parser.on('-h', '--help', 'Show this help message') do
          puts parser
          exit
        end

        parser.separator('')
        parser.separator(commands_help)
        parser.separator('')
        parser.separator(usage_help)
      end
    end

    def commands_help
      commands = COMMAND_ALIASES.map do |command, aliases|
        aliases_str = aliases.map { |name| "'#{name}'" }.join(', ')

        "- '#{command}' (also aliased as #{aliases_str})"
      end

      "Available commands:\n#{commands.join("\n")}"
    end

    def usage_help
      commands = COMMAND_ALIASES.keys.map do |key|
        "- req_wrap #{key} --help"
      end

      "Examples of usage:\n#{commands.join("\n")}"
    end

    def environment(args)
      ReqWrap::Cli::Environment.new.call(args)
    end

    def generate(args)
      ReqWrap::Cli::Generate.new.call(args)
    end

    def find_command(user_command)
      COMMAND_ALIASES.detect do |command_name, command_aliases|
        user_command == command_name || command_aliases.include?(user_command)
      end&.first
    end
  end
end
