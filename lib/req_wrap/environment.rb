# frozen_string_literal: true

require 'dotenv'
require 'active_support/encrypted_file'

module ReqWrap
  # Request environment
  #
  class Environment
    KEY_FILE = '.reqwrap.password'

    def initialize(env_file)
      @env_file = env_file
    end

    def load
      return Dotenv.update(decrypt) if encrypted?

      Dotenv.load(@env_file)
    end

    def decrypt
      encrypted_file.read
    end

    def encrypted?
      @env_file.end_with?('.enc')
    end

    private

    def encrypted_file
      @encrypted_file ||= ActiveSupport::EncryptedFile.new(
        content_path: @env_file,
        key_path: KEY_FILE,
        raise_if_missing_key: true
      )
    end
  end
end
