# frozen_string_literal: true

require 'optparse'

require 'req_wrap/environment'

module ReqWrap
  class Cli
    class Environment
      def initialize
        @options = {
          delete_original: false
        }
      end

      def call(args)
        parser = OptionParser.new(banner) do |p|
          add_gen_pass_option(p)
          add_enc_option(p)
          add_delete_original_option(p)
          add_decrypt_option(p)

          p.separator('')
          p.separator(examples)
        end

        parser.parse!(args)
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
          - req_wrap e --enc env_file.env   # Encrypt environment file env_file.env using generated password
          - E=env_file.env req_wrap e --enc # Encrypt environment file env_file.env using generated password
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
          ReqWrap::Environment.new(env_file || ENV['E']).write_encrypted_environment(
            delete_original: @options[:delete_original]
          )
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
          puts ReqWrap::Environment.new(ENV['E'] || env_file).decrypt
        end
      end
    end
  end
end
