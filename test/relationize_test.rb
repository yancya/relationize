require 'test/unit'
require_relative '../lib/relationize'

class RelationizeTest < Test::Unit::TestCase
  test "that_it_has_a_version_number" do
    refute_nil ::Relationize::VERSION
  end

  using Relationize
  
  test "to_relation" do
    assert_equal(
      %Q{SELECT "id"::INT8, "name"::TEXT FROM (VALUES('1', 'taro'), ('2', 'jiro')) AS "_t"("id", "name")},
      [[1, 'taro'], [2, 'jiro']].to_relation(schema: { id: nil, name: nil }),
    )
  end
end
