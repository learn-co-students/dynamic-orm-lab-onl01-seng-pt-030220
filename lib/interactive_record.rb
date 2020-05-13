require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord
    def self.table_name
        self.to_s.downcase.pluralize
    end

    def self.column_names
        DB[:conn].results_as_hash = true

        table_columns = DB[:conn].execute("pragma table_info('#{table_name}')")
        column_names = []

        table_columns.each do |col|
            column_names << col["name"]
        end
        column_names.compact
    end

    def initialize(attrs={})
        attrs.each do |k, v|
            self.send("#{k}=", v)
        end
    end

    def table_name_for_insert
        self.class.table_name
    end
    
    def values_for_insert
        values = []
        self.class.column_names.each do |col_name|
            values << "'#{send(col_name)}'" unless send(col_name).nil?
        end
        values.join(", ")
    end

    def col_names_for_insert
        self.class.column_names.delete_if {|col| col == "id"}.join(", ")
    end

    def save
        DB[:conn].execute("INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})")
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
    end

    def self.find_by_name(name)
        DB[:conn].execute("SELECT * FROM #{self.table_name} WHERE name = ?", [name])
    end

    def self.find_by(hash)
        DB[:conn].execute("SELECT * FROM #{self.table_name} WHERE #{hash.keys[0].to_s} = '#{hash.values[0].to_s}'")
    end
end