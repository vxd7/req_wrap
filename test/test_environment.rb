# frozen_string_literal: true

require 'test_helper'
require 'req_wrap/environment'

class TestEnvironment < Minitest::Test
  TEST_ENV = <<~ENV
    REQ=wrap
    ABA=caba
    NUM=1
  ENV

  TEST_ENV_FILENAME = 'example.env'
  TEST_ENV_ENC_FILENAME = "#{TEST_ENV_FILENAME}.enc".freeze

  def test_generate_password_file
    path = ReqWrap::Environment.generate_password_file
    refute_empty(File.read(path))
  ensure
    File.delete(path) if File.exist?(path)
  end

  def test_encrypted?
    refute(ReqWrap::Environment.new(TEST_ENV_FILENAME).encrypted?)
    assert(ReqWrap::Environment.new("#{TEST_ENV_FILENAME}.enc").encrypted?)
  end

  def test_plaintext_load
    with_plaintext_test_env do |test_env_path|
      ReqWrap::Environment.new(test_env_path).load

      verify_test_env
    end
  end

  def test_encrypted_load
    with_encrypted_test_env do |test_env_path|
      ReqWrap::Environment.new(test_env_path).load

      verify_test_env
    end
  end

  def test_plaintext_read
    with_plaintext_test_env do |test_env_path|
      actual = ReqWrap::Environment.new(test_env_path).read
      assert_equal(TEST_ENV, actual)
    end
  end

  def test_encrypted_read
    with_encrypted_test_env do |test_env_path|
      actual = ReqWrap::Environment.new(test_env_path).read
      assert_equal(TEST_ENV, actual)
    end
  end

  def test_plaintext_write
    ReqWrap::Environment.new(TEST_ENV_FILENAME).write(TEST_ENV)

    assert_equal(TEST_ENV, File.read(TEST_ENV_FILENAME))
  end

  def test_encrypted_write
    password_file = ReqWrap::Environment.generate_password_file

    ReqWrap::Environment.new(TEST_ENV_ENC_FILENAME).write(TEST_ENV)

    enc_file = ActiveSupport::EncryptedFile.new(
      content_path: TEST_ENV_ENC_FILENAME,
      key_path: password_file,
      env_key: '_DUMMY_ENV_VAR',
      raise_if_missing_key: true
    )
    assert_equal(TEST_ENV, enc_file.read)
  ensure
    File.delete(password_file) if File.exist?(password_file)
  end

  def test_delete
    with_plaintext_test_env do |test_env_path|
      env = ReqWrap::Environment.new(test_env_path)
      env.delete

      refute_path_exists(test_env_path)
    end
  end

  def test_encrypt
    password_file = ReqWrap::Environment.generate_password_file

    with_plaintext_test_env do |test_env_path|
      env = ReqWrap::Environment.new(test_env_path)
      env.encrypt

      enc_env_path = "#{test_env_path}.enc"
      assert_path_exists(enc_env_path)
      assert_path_exists(test_env_path)

      enc_env = ReqWrap::Environment.new(enc_env_path)
      assert_equal(env.read, enc_env.read)
    end
  ensure
    File.delete(password_file) if File.exist?(password_file)
  end

  def test_encrypt_with_delete_original
    password_file = ReqWrap::Environment.generate_password_file

    with_plaintext_test_env do |test_env_path|
      env = ReqWrap::Environment.new(test_env_path)
      env.encrypt(delete_original: true)

      assert_path_exists("#{test_env_path}.enc")
      refute_path_exists(test_env_path)
    end
  ensure
    File.delete(password_file) if File.exist?(password_file)
  end

  def test_change_with_encrypted_file
    new_content = 'NEW=content'
    editor_path = create_ruby_editor(new_content)

    with_encrypted_test_env do |test_env_path|
      env = ReqWrap::Environment.new(test_env_path)

      env.change(editor_path)
      assert_equal("#{TEST_ENV}#{new_content}", env.read)
    end
  ensure
    File.delete(editor_path) if File.exist?(editor_path)
  end

  def test_change_with_plaintext_file
    new_content = 'NEW=content'
    editor_path = create_ruby_editor(new_content)

    with_plaintext_test_env do |test_env_path|
      env = ReqWrap::Environment.new(test_env_path)

      env.change(editor_path)
      assert_equal("#{TEST_ENV}#{new_content}", env.read)
    end
  ensure
    File.delete(editor_path) if File.exist?(editor_path)
  end

  private

  def verify_test_env
    assert_equal('wrap', ENV.fetch('REQ'))
    assert_equal('caba', ENV.fetch('ABA'))
    assert_equal('1', ENV.fetch('NUM'))
  end

  def with_plaintext_test_env
    File.write(TEST_ENV_FILENAME, TEST_ENV)

    yield(TEST_ENV_FILENAME)
  ensure
    File.delete(TEST_ENV_FILENAME) if File.exist?(TEST_ENV_FILENAME)
  end

  def with_encrypted_test_env
    password_file = ReqWrap::Environment.generate_password_file

    enc_file = ActiveSupport::EncryptedFile.new(
      content_path: TEST_ENV_ENC_FILENAME,
      key_path: password_file,
      env_key: '_DUMMY_ENV_VAR',
      raise_if_missing_key: true
    )
    enc_file.write(TEST_ENV)

    yield(TEST_ENV_ENC_FILENAME)
  ensure
    [password_file, TEST_ENV_ENC_FILENAME].each do |fname|
      File.delete(fname) if File.exist?(fname)
    end
  end

  # Simple ruby script which appends text line to the
  # first ARGV argument it receives
  #
  def create_ruby_editor(append_content)
    editor_path = File.expand_path('./editor.rb')

    File.write(editor_path, <<~EDITOR)
      #!/usr/bin/env ruby

      File.write(ARGV.first, '#{append_content}', mode: 'a')
    EDITOR

    File.chmod(0o744, editor_path)

    editor_path
  end
end
