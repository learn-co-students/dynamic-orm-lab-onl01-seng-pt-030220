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
        
    end
end