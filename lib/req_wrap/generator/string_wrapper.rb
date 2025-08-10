# frozen_string_literal: true

module ReqWrap
  module Generator
    module StringWrapper
      def self.wrap_string(str, to:)
        wrap_words(str.split(' '), [], to).map { |words| words.join(' ') }
      end

      def self.wrap_words(words, result, to)
        # Partitioning is finished if there is nothing more to
        # partition;
        #
        return result if words.empty?

        current_size = 0
        line, rest = words.partition do |word|
          current_size += word.size + 1
          current_size - 1 <= to
        end

        # Use the next word if wrapping cannot be performed;
        #
        # This means that the word length is larger than the 'to'
        # argument
        #
        line << rest.shift if line.empty?

        result << line

        # Continue partitioning the rest of words
        #
        wrap_words(rest, result, to)
      end
    end
  end
end
