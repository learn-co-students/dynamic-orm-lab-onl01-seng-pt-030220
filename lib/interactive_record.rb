require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class InteractiveRecord

def self.table_name
self.to_s.downcase.pluralize
end

def self.column_names
DB[:conn].results_as_hash = true
sql = "PRAGMA table_info('#{table_name}')"
table_info = DB[:conn].execute(sql)
names = []
table_info.each do|row|
  names << row["name"]
end
names.compact
end

  def self.make_attr_accessor
    self.column_names.each do |col_name|
    attr_accessor col_name.to_sym
  end
  end


def initialize(inputs={})
    self.class.make_attr_accessor
    inputs.each do |key, value|
    self.send("#{key}=", value)
  end
end

def table_name_for_insert
self.class.table_name
end

def col_names_for_insert
  self.class.column_names.delete_if{|column|column == 'id'}.join(", ")
end

def values_for_insert
values = []
  self.class.column_names.each do |column_title|
  values << "'#{send(column_title)}'" unless send(column_title) == nil?
end
values.delete_at(0)
values.join(", ")
end


def save
  sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
  DB[:conn].execute(sql)
  @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
end


def self.find_by_name(input)
  DB[:conn].execute("SELECT * FROM #{self.table_name} WHERE name = ?", input)

end

def self.find_by(attribute)
  sql = "SELECT * FROM #{self.table_name} WHERE #{attribute.keys[0].to_s} = '#{attribute.values[0].to_s}'"
  DB[:conn].execute(sql)


end

end
