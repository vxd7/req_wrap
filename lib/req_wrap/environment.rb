# frozen_string_literal: true

require 'dotenv'
require 'tempfile'
require 'active_support/encrypted_file'

module ReqWrap
  # Request environment
  #
  class Environment
    PASSWORD_FILE = '.reqwrap_password'
    ENCRYPTED_ENV_FILE_EXT = '.enc'

    def self.generate_password_file
      path = File.expand_path("./#{PASSWORD_FILE}")
      raise ArgumentError, 'Password file already exists' if File.exist?(path)

      File.write(path, ActiveSupport::EncryptedFile.generate_key)
      path
    end

    def initialize(env_file = nil)
      @env_file = env_file || default_env_file
    end

    def encrypted?
      @env_file.end_with?(ENCRYPTED_ENV_FILE_EXT)
    end

    def load
      return unless validate

      load_str_environment(read)
    end

    def read
      return decrypt if encrypted?

      File.read(@env_file, mode: 'rb:BOM|utf-8')
    end

    def write(content)
      return encrypted_file_for(@env_file).write(content) if encrypted?

      File.write(@env_file, content)
    end

    def delete
      File.delete(@env_file) if File.exist?(@env_file)
    end

    def encrypt(delete_original: false)
      validate(raise_error: true)

      Environment.new("#{@env_file}#{ENCRYPTED_ENV_FILE_EXT}").write(read)
      delete if delete_original
    end

    def change(editor)
      return change_encrypted_environment(editor) if encrypted?

      Tempfile.create(['', "-#{@env_file}"]) do |tmp_file|
        original_content = read
        tmp_file.write(original_content)
        tmp_file.flush

        launch_external_editor(editor, tmp_file.path)

        tmp_file.rewind
        new_content = tmp_file.read
        write(new_content) if original_content != new_content
      end
    end

    private

    def change_encrypted_environment(editor)
      encrypted_file_for(@env_file).change do |decrypted_file_path|
        launch_external_editor(editor, decrypted_file_path)
      end
    end

    def decrypt
      validate(raise_error: true)
      encrypted_file_for(@env_file).read
    end

    # Default env file is given by 'E' environment variable
    # and will be used by different scripts and classes of this gem;
    #
    def default_env_file
      ENV['E']
    end

    # Update current environment from supplied
    # unparsed str
    #
    def load_str_environment(environment_str)
      Dotenv.update(Dotenv::Parser.new(environment_str).call)
    end

    def encrypted_file_for(content_path)
      ActiveSupport::EncryptedFile.new(
        content_path: content_path,
        key_path: PASSWORD_FILE,
        env_key: 'REQWRAP_PASSWORD',
        raise_if_missing_key: true
      )
    end

    def validate(raise_error: false)
      unless @env_file
        return false unless raise_error

        raise ArgumentError, 'Env file not supplied'
      end

      unless File.exist?(@env_file)
        return false unless raise_error

        raise ArgumentError, 'Env file does not exist'
      end

      true
    end

    def launch_external_editor(editor, file_path)
      system(editor, file_path.to_s)
    end
  end
end
