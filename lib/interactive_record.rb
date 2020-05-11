require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class InteractiveRecord

    def self.table_name
        self.to_s.downcase.pluralize
    end

    def self.column_names
        DB[:conn].results_as_hash = true
        sql = "pragma table_info('#{table_name}')"
        table_info = DB[:conn].execute(sql)
        column_names = []
        table_info.each do |col|

            column_names << col["name"]
        end
        column_names.compact
    end
    
    def initialize(attributes={})
        attributes.each do |key, value|
            self.send("#{key}=", value)
        end
    end

    def table_name_for_insert
        self.class.table_name
    end
    
    def col_names_for_insert
        column_names = self.class.column_names.delete_if {|val| val == "id"}.join(", ")
        #binding.pry
    end

    def values_for_insert
        values = []
        self.class.column_names.each do |col_name|
            values << "'#{send(col_name)}'" unless send(col_name).nil?
        end
        values.join(", ")
    end

    def save
        sql = <<-SQL
        INSERT INTO #{table_name_for_insert} (#{col_names_for_insert})
        VALUES (#{values_for_insert})
        SQL
        DB[:conn].execute(sql)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
    end

    def self.find_by_name(name)
        sql = <<-SQL
        SELECT * FROM #{table_name}
        WHERE name = ?
        SQL
        DB[:conn].execute(sql, name)
    end

    def self.find_by(attributes)
        column = []
        column_val = []
        attributes.each do |key, value|
            column << key.to_s
            if value.to_i == 0
                column_val << "'#{value}'"
            else 
                column_val << value
            end
        end

        if column.length == 1
            string = "#{column.join()} = #{column_val.join()}"
        else 
            string = "#{column[0].to_s} = #{val[0].to_s} AND #{column[1].to_s} = #{val[1].to_s}"
        end

        sql = <<-SQL
        SELECT * FROM #{table_name}
        WHERE #{string}
        SQL

        DB[:conn].execute(sql)
    end
end