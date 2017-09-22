require_relative 'db_connection'
require 'active_support/inflector'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.
require 'byebug'
class SQLObject
  def self.columns
    @a ||= DBConnection.execute2(<<-SQL)
    SELECT
      *
    FROM
      "#{table_name}"
    SQL
    @a.first.map{|el| el.to_sym}
  end

  def self.finalize!

    self.columns.each do |col|

      define_method(col){ attributes[col] }

      define_method("#{col}=") {|value| attributes[col] = value }

    end


  end

  def self.table_name=(table_name)
    # ...
  end

  def self.table_name
    "#{self.name}s".downcase
  end

  def self.all
    # debugger
    lol = DBConnection.execute(<<-SQL)
      SELECT
          #{self.table_name}.*
      FROM
        #{self.table_name}
    SQL
    self.parse_all(lol)
  end

  def self.parse_all(results)
    # debugger
    res = []
    results.each do |el|
      # debugger
      res << self.new(el)
    end
    res
    # ...
  end

  def self.find(id)

    # debugger
    return nil if self.all.select{|el| el.id == id}.empty?
    self.all.select{|el| el.id == id}.first
  end

  def initialize(params = {})
    params.each do |attr_name, value|
      # debugger
      unless (self.class.columns.join(',').split(',')).include?(attr_name.to_s)
        raise "unknown attribute '#{attr_name}'"
      else
        # debugger
        self.send("#{attr_name}=",value)
      end

    end
    # ...
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    @attributes.values
    # ...
  end

  def insert

    string_q = ''
    attribute_values.length.times do
      string_q << '?, '
    end
    string = string_q[0..-3]
    # debugger
    DBConnection.execute(<<-SQL, *attribute_values)
      INSERT INTO
        #{self.class.table_name} (#{self.class.columns[1..-1].join(',')})
      VALUES
        (#{string})
    SQL
    self.id = DBConnection.last_insert_row_id
  end

  def update
    str = self.class.columns.join('=? ,') + '=?'
    # debugger

    DBConnection.execute(<<-SQL, *attribute_values)
    UPDATE
      #{self.class.table_name}
    SET
      #{str}
    WHERE
      id = #{self.id}
    SQL
    # ...
  end

  def save
    !self.attributes[:id].nil? ? self.update : self.insert
    # ...
  end
end
