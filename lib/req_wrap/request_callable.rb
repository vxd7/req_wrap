# frozen_string_literal: true

module ReqWrap
  module RequestCallable
    def call(...)
      requested_at = clock_monotonic
      @response = super
      responded_at = clock_monotonic

      @elapsed_time = responded_at - requested_at
      @response
    end

    private

    def clock_monotonic
      Process.clock_gettime(Process::CLOCK_MONOTONIC)
    end
  end
end
