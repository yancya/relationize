require_relative './relationizer'
require 'date'
require 'bigdecimal'

module Relationize
  class BqRelationizer < Relationizer
    BQ_TS_FMT = "%Y-%m-%d %H:%M:%S %:z"
    
    DEFAULT_TYPES = {
      Integer    => :integer,
      Fixnum     => :integer,
      Bignum     => :integer,
      BigDecimal => :integer,
      Float      => :float,
      String     => :string,
      TrueClass  => :boolean,
      FalseClass => :boolean,
      Date       => :string,
      Time       => :timestamp
    }

    def self.to_text_literal(obj)
      obj.nil? ? 'NULL' : obj.to_s.gsub(/'/, "\\'").tap { |s| break "'#{s}'" }
    end

    def self.to_timestamp_string(obj)
      to_text_literal(obj.is_a?(Time) ? obj.strftime(BQ_TS_FMT) : obj)
    end

    CAST = {
      "INTEGER"   => -> (val, col) { "INTEGER(#{to_text_literal(val)}) AS #{col}"},
      "FLOAT"     => -> (val, col) { "FLOAT(#{to_text_literal(val)}) AS #{col}" },
      "BOOLEAN"   => -> (val, col) { "BOOLEAN(#{val.nil? ? 'NULL' : (val ? 1 : 0)}) AS #{col}" },
      "STRING"    => -> (val, col) { "STRING(#{to_text_literal(val)}) AS #{col}"},
      "TIMESTAMP" => -> (val, col) { "TIMESTAMP(#{to_timestamp_string(val)}) AS #{col}"}
    }

    def to_s
      rows = @tuples.map { |tuple|
        "(SELECT #{tuple.zip(@columns).zip(oriented_types).map(&method(:to_row)).join(', ')})"
      }.join(', ')
      "SELECT * FROM (SELECT * FROM #{rows}) AS #{@name}"
    end

    def to_row(((val, col), type))
      CAST[type][val, col]
    end
  end
end
