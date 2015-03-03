# encoding: UTF-8

require 'yaml'

require 'rubygems'
require Rails.root.join('config', 'environment.rb')

require 'differ'
require 'db2_helper'

class Database <  ActiveRecord::Base; end

class Checker

    def initialize
        @config = YAML.load_file Rails.root.join('config', 'dbdiff.yml')

        verifications = @config['databases'].map{|database_config| check( database_config ) }

        @config['comparisons'].each do |comparison_config|
          verification_from = verifications.select{|v| v.database == comparison_config['database_from'] }.first
          verification_to = verifications.select{|v| v.database == comparison_config['database_to'] }.first
        
          differ = Differ.new( verification_to, verification_from )

          structures_diff_html = differ.structures_diff.inject({}) do |hash, structure_diff|
            hash[structure_diff.schema] = structure_diff.diff.to_s(:html)
            hash
          end

          comparison = Comparison.new( :result => differ.result, :structures_diff => structures_diff_html, :tables_diff => differ.tables_diff )
          comparison.verification_from = verification_from
          comparison.verification_to = verification_to
          comparison.save!

        end
    end

private

    def check( database_config )

        started = Time.now

        puts "Starting check database #{database_config['name']}"

        Database.establish_connection( database_config )

        verification = Verification.new( :database => database_config['name'], :date => started )
        verification.database = database_config['database']

        begin
            check_structures( verification, database_config )
            check_tables_data( verification )

            verification.result = true
        rescue => e
            puts e.message
            verification.error_message = e.message
            verification.result = false
        end

        verification.duration = Time.now - started
        verification.save!

        return verification
    end

    # Temporario
    DIRECTORY_DUMPS = Rails.root.join('dumps/') # "/var/www/html/DBDiff/dumps/"

    def check_structures( verification, database_config )
   
      database_helper = case database_config['adapter']
      
        when 'ibm_db' then DB2Helper.new( database_config, @config['schemas'] )

        else
          raise 'Database type unknown'

      end

      structure_dump_infos = database_helper.create_dumps( DIRECTORY_DUMPS )

      structure_dump_infos.each do |schema, dump_filename|
        verification.structures << Structure.new( :dump_filename => dump_filename, :schema => schema )
      end

    end

    def check_tables_data( verification )
        
        @config['tables'].each do |table|

            #klass = Class.new(ActiveRecord::Base) do
            #    set_table_name table['name']
            #    establish_connection database_config 
            #end

            #klass.establish_connection( database_config )

            #puts klass.attributes
           
            r = Database.find_by_sql("SELECT * FROM #{table['name']} ORDER BY 1")

            records = TableDataVersion::Records.new(r.first.attributes.keys, r[1..-1].map{|row| row.attributes.values })

            verification.table_data_versions << TableDataVersion.new( :table => table['name'], :records => records )

        end
 
    end

end
