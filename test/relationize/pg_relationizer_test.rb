require "test-unit"
require_relative "../../lib/relationize/pg_relationizer.rb"

class PgRelationizerTest < Test::Unit::TestCase
  data(
    'Fixnum -> INT8' => [
      [[[1, 99], [2, 1000], [3, 980]], { id: nil, amount: nil }, "amounts"],
      %Q{SELECT "id"::INT8, "amount"::INT8 FROM (VALUES('1', '99'), ('2', '1000'), ('3', '980')) AS "amounts"("id", "amount")}
    ],
    'String -> TEXT' => [
      [[[1, 'aaaa'], [2, 'bbbb']], { id: 'INTEGER', name: "TEXT"}, "users"],
      %Q{SELECT "id"::INTEGER, "name"::TEXT FROM (VALUES('1', 'aaaa'), ('2', 'bbbb')) AS "users"("id", "name")}
    ],
    'Bignum -> DECIMAL' => [
      [[[10_000_000_000_000_000_000]], { n: nil }, "bignum"],
      %Q{SELECT "n"::DECIMAL FROM (VALUES('10000000000000000000')) AS "bignum"("n")}
    ],
    'Bignum -> DECIMAL(20, 0)' => [
      [[[10_000_000_000_000_000_000]], { n: "DECIMAL(20, 0)" }, "bignum"],
      %Q{SELECT "n"::DECIMAL(20, 0) FROM (VALUES('10000000000000000000')) AS "bignum"("n")}
    ],
    'BigDecimal -> DECIMAL' => [
      [[[BigDecimal.new('7304720470.1241274981346911')]], { d: nil }, 'decimals'],
      %Q{SELECT "d"::DECIMAL FROM (VALUES('0.73047204701241274981346911E10')) AS "decimals"("d")}
    ],
    'Float -> FLOAT8' => [
      [[[0.0001], [0.000002]], { f: nil }, "floats"],
      %Q{SELECT "f"::FLOAT8 FROM (VALUES('0.0001'), ('2.0e-06')) AS "floats"("f")}
    ],
    'TrueFalse -> BOOLEAN' => [
      [[[true], [false]], { flag: nil }, "flags"],
      %Q{SELECT "flag"::BOOLEAN FROM (VALUES('true'), ('false')) AS "flags"("flag")}
    ],
    'Date -> DATE' => [
      [[['taro', Date.parse('2016-03-22')]], { name: nil, birthday: nil }, "users"],
      %Q{SELECT "name"::TEXT, "birthday"::DATE FROM (VALUES('taro', '2016-03-22')) AS "users"("name", "birthday")}
    ],
    'Time -> TIMESTAMPTZ' => [
      [[[Time.new(2016, 3, 22, 15, 10, 10, '+09:00')]], { t: nil }, 'times'],
      %Q{SELECT "t"::TIMESTAMPTZ FROM (VALUES('2016-03-22 15:10:10 +0900')) AS "times"("t")}
    ],
    %Q{O'Reilly Japan} => [
      [[[%Q{O'Reilly Japan}]], { name: nil }, 'publishers'],
      %Q{SELECT "name"::TEXT FROM (VALUES('O''Reilly Japan')) AS "publishers"("name")}
    ],
    "Identifer quote" => [
      [[[1], [2]], { ";\"a": nil}, '"a;"'],
      %Q{SELECT ";""a"::INT8 FROM (VALUES('1'), ('2')) AS """a;"""(";""a")}
    ],
    "INT8RANGE" => [
      [[['[1,10]'], ['[1,]']], { r: :INT8RANGE }, 'ranges'],
      %Q{SELECT "r"::INT8RANGE FROM (VALUES('[1,10]'), ('[1,]')) AS "ranges"("r")}
    ]
  )
  test "Case" do |((data, types, name), expected)|
    rel = Relationize::PgRelationizer.new(data, types, name).to_s
    assert_equal(rel, expected)
  end

  test "Error: Many candidate of type" do
    assert_raise(Relationize::PgRelationizer::ReasonlessTypeError) do
      Relationize::PgRelationizer.new([[1], ['a']], { c: nil }, '_t').to_s
    end
  end

  test "Error: Type candidate nothing" do
    assert_raise(Relationize::PgRelationizer::ReasonlessTypeError) do
      Relationize::PgRelationizer.new([[Object.new], [Object.new]], { o: nil }, '_t').to_s
    end
  end
end
