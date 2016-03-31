[![Build Status](https://travis-ci.org/yancya/relationize.svg?branch=master)](https://travis-ci.org/yancya/relationize)

# Relationize

This gem convert Array to String of SQL relation.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'relationize'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install relationize

## Usage

```ruby
using Relationize

array = [[1, 2], [4, 5]]

puts array.to_relation(schema: { a: nil, b: :decimal })
#=> SELECT "a"::INT8, "b"::DECIMAL FROM (VALUES('1', '2'), ('4', '5')) AS "_t"("a", "b")

puts array.to_relation(schema: { a: nil, b: nil }, db: :bq)
#=> SELECT * FROM (SELECT * FROM (SELECT INTEGER('1') AS a, INTEGER('2') AS b), (SELECT INTEGER('4') AS a, INTEGER('5') AS b)) AS _t

puts [["'a'"]].to_relation(schema: { a: nil })
#=> SELECT "a"::TEXT FROM (VALUES('''a''')) AS "_t"("a")
```

### Usage for PostgreSQL

```ruby
require 'relationize'
require 'pg'

using Relationize

sql = [
  [1, 2, 3],
  [4, 5, 6]
].to_relation(schema: {a: nil, b: nil, c: :decimal})

p PG.connect.exec(sql).to_a
#=> [{"a"=>"1", "b"=>"2", "c"=>"3"}, {"a"=>"4", "b"=>"5", "c"=>"6"}]

p PG.connect.exec(<<-SQL).to_a #=> [{"a"=>"1", "b"=>"2", "c"=>"3"}]
SELECT * FROM (#{sql}) AS t WHERE "a" < 3
SQL

p PG.connect.exec(<<-SQL).to_a #=> [{"a"=>"4", "b"=>"5", "c"=>"6"}]
  WITH t AS (#{sql})
SELECT * FROM t WHERE t."a" > 3
SQL
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/yancya/relationize.

