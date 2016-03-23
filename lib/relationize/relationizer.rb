module Relationize
  #
  # Relationizer Base Class 
  #
  class Relationizer
    class InvalidElementError < StandardError; end
    class InvalidSchemaError < StandardError; end
    class ReasonlessTypeError < StandardError; end

    #
    # @param [Array] tuples: Expected to two dimentional Array. For example `[[1, 2], [3, 4]]`
    # @param [Hash] schema: For example `{ id: :integer, amount: :integer}`
    # @param [String] name: Relation name
    #
    def initialize(tuples, schema, name)
      unless tuples.all? { |o| o.is_a?(Array) }
        raise InvalidElementError.new("Element should be Array")
      end

      unless tuples.map(&:length).all? { |length| length == schema.length }
        raise InvalidSchemaError.new("Tuple size is expected #{schema.length}.")
      end
      
      @tuples, @name, @columns, @types = tuples, name, schema.keys, schema.values
    end

    private

    def identifer_quote(w)
      %Q{"#{w.to_s.gsub(/"/, '""')}"}
    end

    def oriented_types
      @tuples.transpose.zip(@types).map do |(values, type)|
        next type.to_s.upcase if type

        values.map(&:class).uniq.
          map { |klass| self.class::DEFAULT_TYPES[klass] }.compact.uniq.
          tap { |types| raise ReasonlessTypeError.new("Many candidate: #{types.join(', ')}") unless types.one? }.
          tap { |types| raise ReasonlessTypeError.new("Candidate nothing") if types.empty? }.
          first.to_s.upcase
      end
    end
  end
end
