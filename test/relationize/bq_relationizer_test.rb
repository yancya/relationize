require "test-unit"
require_relative "../../lib/relationize/bq_relationizer.rb"

class BqRelationizerTest < Test::Unit::TestCase
  data(
    'Integer -> String' => [
      [[[1], [nil]], { n: :string }, '_t'],
      %Q{SELECT * FROM (SELECT * FROM (SELECT STRING('1') AS n), (SELECT STRING(NULL) AS n)) AS _t}
    ],
    'TrueFalse -> Boolean' => [
      [[[true, false, nil]], { b1: nil, b2: nil, b3: :boolean }, '_t'],
      %Q{SELECT * FROM (SELECT * FROM (SELECT BOOLEAN(1) AS b1, BOOLEAN(0) AS b2, BOOLEAN(NULL) AS b3)) AS _t}
    ],
    'Float -> Float' => [
      [[[0.01, nil]], { f1: nil, f2: :float }, '_t'],
      %Q{SELECT * FROM (SELECT * FROM (SELECT FLOAT('0.01') AS f1, FLOAT(NULL) AS f2)) AS _t}
    ],
    'Fixnum -> Integer' => [
      [[[1, nil]], { i1: nil, i2: :integer }, '_t'],
      %Q{SELECT * FROM (SELECT * FROM (SELECT INTEGER('1') AS i1, INTEGER(NULL) AS i2)) AS _t}
    ],
    'Time -> Timestamp' => [
      [[[Time.new(2016, 3, 23, 18, 0, 0, '+09:00'), nil]], { t1: nil, t2: :timestamp }, '_t'],
      %Q{SELECT * FROM (SELECT * FROM (SELECT TIMESTAMP('2016-03-23 18:00:00 +09:00') AS t1, TIMESTAMP(NULL) AS t2)) AS _t}
    ],
    'Time -> String' => [
      [[[Time.new(2016, 3, 23, 18, 0, 0, '+09:00')]], { t1: :string }, '_t'],
      %Q{SELECT * FROM (SELECT * FROM (SELECT STRING('2016-03-23 18:00:00 +0900') AS t1)) AS _t}
    ]
  )
  test "Case" do |((data, types, name), expected)|
    assert_equal(Relationize::BqRelationizer.new(data, types, name).to_s, expected)
  end
end
