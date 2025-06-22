# frozen_string_literal: true

require 'dotenv'
require 'active_support/encrypted_file'

module ReqWrap
  # Request environment
  #
  class Environment
    PASSWORD_FILE = '.reqwrap_password'
    ENCRYPTED_ENV_FILE_EXT = '.enc'

    def self.generate_password_file
      raise ArgumentError, 'Password file already exists' if File.exist?(PASSWORD_FILE)

      File.write(PASSWORD_FILE, ActiveSupport::EncryptedFile.generate_key)
    end

    def initialize(env_file)
      raise ArgumentError, 'Env file not supplied' unless env_file
      raise ArgumentError, 'Env file does not exist' unless File.exist?(env_file)

      @env_file = env_file
    end

    def load
      return load_str_environment(decrypt) if encrypted?

      Dotenv.load(@env_file)
    end

    def write_encrypted_environment(delete_original: false)
      encrypted_file_for("#{@env_file}#{ENCRYPTED_ENV_FILE_EXT}").write(
        File.read(@env_file, mode: 'rb:BOM|utf-8')
      )

      File.delete(@env_file) if delete_original
    end

    def decrypt
      encrypted_file_for(@env_file).read
    end

    private

    # Update current environment from supplied
    # unparsed str
    #
    def load_str_environment(environment_str)
      Dotenv.update(Dotenv::Parser.new(environment_str).call)
    end

    def encrypted?
      @env_file.end_with?(ENCRYPTED_ENV_FILE_EXT)
    end

    def encrypted_file_for(content_path)
      ActiveSupport::EncryptedFile.new(
        content_path: content_path,
        key_path: PASSWORD_FILE,
        env_key: 'REQWRAP_PASSWORD',
        raise_if_missing_key: true
      )
    end
  end
end
