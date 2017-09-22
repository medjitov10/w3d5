require_relative 'db_connection'
require_relative '01_sql_object'
require "byebug"
module Searchable
  def where(params)
    str = []

    params.each do |k,v|
      if v.is_a?(String)
        str << "#{k}= '#{v}'"
      else
        str << "#{k}= #{v}"
      end
    end

    str = str.join(' AND ')
    # debugger
    var = DBConnection.execute(<<-SQL)
    SELECT
      *
    FROM
      #{self.table_name}
    WHERE
      #{str}
    SQL
    var.map do |el|
      self.new(el)
    end
  end
end

class SQLObject
  # Mixin Searchable here...
  extend Searchable
end
