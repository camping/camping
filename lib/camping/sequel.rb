class MissingLibrary < Exception #:nodoc: all
end
begin
    require 'sequel'
rescue LoadError => e
    raise MissingLibrary, "Sequel gem could not be loaded (is it installed?): #{e.message}"
end

$SEQUEL_EXTRAS = %{
  Sequel::Model.plugin :timestamps
  Base = Sequel::Model

  # class SchemaInfo < Base
  # end
}

module Camping
  module Models
    module_eval $SEQUEL_EXTRAS
  end
end

Camping::S.sub!(/autoload\s*:Base\s*,\s*['"]camping\/sequel['"]/, $SEQUEL_EXTRAS)
Camping::Apps.each do |c|
  c::Models.module_eval $SEQUEL_EXTRAS.gsub('Camping', c.to_s)
end

ENV['DATABASE_URL'] = 'db/camp.db' if ENV['DATABASE_URL'] == ''

# connect to a database by default
DB = Sequel.connect(ENV['DATABASE_URL'])
