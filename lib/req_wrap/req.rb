# frozen_string_literal: true

require 'logger'
require 'http'
require 'active_support/core_ext/string'

require 'req_wrap/environment'
require 'req_wrap/http_features/response_store'

module ReqWrap
  DEFAULT_LOGGER = Logger.new($stdout)

  class Req
    attr_reader :responses

    def initialize(timeout: 10, logger: DEFAULT_LOGGER, response_store: [])
      @timeout = timeout
      @logger = logger
      @responses = response_store
    end

    def load_env
      Environment.new.load
    end

    def save_response(response_to_save = response, name: nil)
      req_class = self.class.name.demodulize.underscore
      time = Time.now.utc.iso8601(4)
      filename = [req_class, time, name, 'response.txt'].join('_')

      File.write(filename, response_to_save)

      filename
    end

    def response
      @responses.last
    end

    def executed_request
      response&.request
    end

    def to_s
      response.is_a?(HTTP::Response) ? response.parse : response
    end

    private

    def e(name)
      ENV.fetch(name.to_s.upcase)
    end

    def without_ssl(client)
      ctx = OpenSSL::SSL::SSLContext.new
      ctx.verify_mode = OpenSSL::SSL::VERIFY_NONE

      client.default_options = client.default_options.with_ssl_context(ctx)
      client
    end

    def http_json
      http.headers(content_type: 'application/json')
    end

    def http
      client = HTTP.timeout(@timeout).use(:auto_inflate)
      client = client.use(logging: { logger: @logger }) if @logger
      client = client.use(response_store: { store: @responses }) if @responses

      client
    end
  end
end
