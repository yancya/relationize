require_relative './relationizer'
require 'bigdecimal'
require 'date'

module Relationize
  class PgRelationizer < Relationizer
    DEFAULT_TYPES = {
      Integer    => :int8,
      Fixnum     => :int8,
      Bignum     => :decimal,
      BigDecimal => :decimal,
      Float      => :float8,
      String     => :text,
      TrueClass  => :boolean,
      FalseClass => :boolean,
      Date       => :date,
      Time       => :timestamptz
    }

    def to_s
      types = oriented_types
      columns = @columns.map(&method(:identifer_quote))
      tuples = @tuples.map { |tuple| "(#{tuple.map { |v| to_text_literal(v) }.join(', ')})"}.join(", ")
      expressions = columns.zip(types).map { |(col, type)| "#{col}::#{type}" }.join(', ')
      "SELECT #{expressions} FROM (VALUES#{tuples}) AS #{identifer_quote(@name)}(#{columns.join(', ')})"
    end

    private

    def to_text_literal(obj)
      obj.to_s.gsub(/'/, "''").tap do |s|
        break "'#{s}'"
      end
    end
  end
end
