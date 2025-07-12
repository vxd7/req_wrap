# frozen_string_literal: true

require 'erb'
require 'active_support/inflector/methods'
require 'req_wrap/generator/string_wrapper'

module ReqWrap
  module Generator
    class Req
      TEMPLATE = "#{File.dirname(__FILE__)}/req.erb".freeze
      RUBY_EXT = '.rb'

      def initialize(request_file, options = {})
        @request_file = ensure_extension(request_file, RUBY_EXT)
        @request_name = File.basename(@request_file, RUBY_EXT)

        @options = options
      end

      def call
        File.write(
          @request_file,
          template.result_with_hash(template_options)
        )
      end

      private

      def template_options
        @template_options ||= {
          request_class_name: ActiveSupport::Inflector.camelize(@request_name),
          request_name: @request_name,
          request_description: prepare_request_description
        }
      end

      def ensure_extension(file_name, extension)
        return file_name if file_name.end_with?(extension)

        "#{file_name}#{extension}"
      end

      def template
        @template ||= ERB.new(File.read(TEMPLATE), trim_mode: '-').tap do |erb|
          erb.location = [TEMPLATE, 0]
        end
      end

      def prepare_request_description
        request_description = @options[:request_description]
        return unless request_description
        return if request_description.empty?

        lines = StringWrapper.wrap_string(request_description, to: 79)
        lines << ''
        lines.map { |line| "# #{line}" }.join("\n")
      end
    end
  end
end
