# frozen_string_literal: true

require 'http'

module ReqWrap
  module HttpFeatures
    class ResponseStore < ::HTTP::Feature
      def initialize(store:)
        super()

        raise ArgumentError, 'Provide data structure to store responses' unless store

        @store = store
      end

      def wrap_response(response)
        @store.append(response)

        response
      end

      ::HTTP::Options.register_feature(:response_store, self)
    end
  end
end
