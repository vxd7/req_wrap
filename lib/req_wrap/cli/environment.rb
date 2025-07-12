# frozen_string_literal: true

require 'optparse'

require 'req_wrap/environment'

module ReqWrap
  class Cli
    class Environment
      DEFAULT_EDITOR = 'vi'

      def initialize
        @options = {
          delete_original: false
        }
      end

      def call(args) # rubocop:disable Metrics/MethodLength
        parser = OptionParser.new(banner) do |p|
          add_gen_pass_option(p)
          add_enc_option(p)
          add_change_option(p)
          add_delete_original_option(p)
          add_decrypt_option(p)

          p.separator('')
          p.separator(examples)
        end

        return parser.parse!(args) unless args.empty?

        puts parser
        exit(1)
      end

      private

      def banner
        <<~BANNER
          Usage: req_wrap e [options...]

          Manage environment files used by request scripts
        BANNER
      end

      def examples
        <<~EXAMPLES
          Examples of invocation:
          - req_wrap e --gen-pass                     # Generate encryption password
          - req_wrap e --enc env_file.env             # Encrypt environment file env_file.env using generated password
          - E=env_file.env req_wrap e --enc           # Encrypt environment file env_file.env using generated password
          - EDITOR=vim req_wrap e --edit env_file.enc # Decrypt environment file, open editor and re-encrypt
        EXAMPLES
      end

      def add_gen_pass_option(parser)
        parser.on('--gen-pass', "Generate password file ('#{ReqWrap::Environment::PASSWORD_FILE}')") do
          ReqWrap::Environment.generate_password_file
        end
      end

      def add_enc_option(parser)
        desc = 'Encrypt environment file and write the result to env_file.enc file'

        parser.on('--enc [env_file]', desc) do |env_file|
          ReqWrap::Environment.new(env_file).encrypt(
            delete_original: @options[:delete_original]
          )
        end
      end

      def add_change_option(parser)
        desc = 'Edit encrypted environment using supplied text editor'

        parser.on('--change [enc_file]', desc) do |env_file|
          ReqWrap::Environment.new(env_file).change(ENV.fetch('EDITOR', DEFAULT_EDITOR))
        end
      end

      def add_delete_original_option(parser)
        desc = 'Delete original environment file after encryption'

        parser.on('--delete-original', desc) do
          @options[:delete_original] = true
        end
      end

      def add_decrypt_option(parser)
        parser.on('--decrypt [env_file]', 'Decrypt env file and print it to stdout') do |env_file|
          puts ReqWrap::Environment.new(env_file).read
        end
      end
    end
  end
end
