require_relative 'relationize/version'

require_relative 'relationize/pg_relationizer'
require_relative 'relationize/bq_relationizer'

module Relationize
  PG = :pg
  BQ = :bq

  RELATIONIZERS = {
    PG => PgRelationizer,
    BQ => BqRelationizer
  }

  refine Array do
    def to_relation(db: PG, schema:, name: '_t')
      RELATIONIZERS[db].new(self, schema, name).to_s
    end
  end
end
