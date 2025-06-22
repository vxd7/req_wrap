# frozen_string_literal: true

require 'logger'
require 'http'

require 'req_wrap/environment'
require 'req_wrap/request_callable'

module ReqWrap
  DEFAULT_LOGGER = Logger.new($stdout)

  class Req
    attr_reader :response, :elapsed_time

    def self.inherited(subclass)
      subclass.prepend(RequestCallable)

      super
    end

    def initialize(timeout: 10, logger: DEFAULT_LOGGER)
      @timeout = timeout
      @logger = logger
    end

    def load_env
      Environment.new.load
    end

    def to_s
      call unless @response

      @response.is_a?(HTTP::Response) ? @response.parse : @response
    end

    def executed_request
      @response&.request
    end

    def save_response
      req_class = self.class.name.demodulize.underscore
      time = Time.now.utc.iso8601(4)
      filename = "#{req_class}_#{time}_response.txt"

      File.write(filename, @response)

      filename
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
      client = HTTP.timeout(@timeout)
      client = client.use(logging: { logger: @logger }) if @logger

      client
    end
  end
end
