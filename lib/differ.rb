require 'rubygems'
require 'htmldiff'
require 'diffy'

class Differ

  attr_accessor :result, :structures_diff, :tables_diff

  module Result
    INVALID = 0
    EQUAL = 1
    DIFFERENT = 2
  end

  StructureDiff = Struct.new(:schema, :diff)

  TableDiff = Struct.new(:table_name, :columns, :rows)

  RowDiff = Struct.new(:type, :data) do
    def inserted?; type == RowDiffType::INSERT; end
    def deleted?; type == RowDiffType::DELETE; end
    def modified?; type == RowDiffType::MODIFY; end
  end

  module RowDiffType
    NONE = 0
    INSERT = 1
    DELETE = 2
    MODIFY = 3
  end

  def initialize(to, from)
    @verification_to = to
    @verification_from = from

    @structures_diff = []
    @tables_diff = []

    if !@verification_to.result || !@verification_from.result

      @result = Result::INVALID

      return
    end

    @result = Result::EQUAL

    @config = YAML.load_file Rails.root.join('config', 'dbdiff.yml')

    start_at = Time.now

    diff_structures

    puts "Diff structures in #{Time.now - start_at} s"

    start_at = Time.now

    diff_tables_data

    puts "Diff tables data in #{Time.now - start_at} s"

  end

private

  def diff_structures

    structures_to = @verification_to.structures
    structures_from = @verification_from.structures

    @structures_diff = structures_to.map do |structure_to|

      structure_from = structures_from.select{|s| s.schema == structure_to.schema }.first

      next if structure_from.nil?

      diff = Diffy::Diff.new(
        structure_from.dump_filename,
        structure_to.dump_filename,
        :source => 'files',
        :diff => ["-b", "-B", "-w", "-d", "-U 5"],
        :include_diff_info => true,
        :include_plus_and_minus_in_html => true )
 
      @result = Result::DIFFERENT if diff.each_chunk.to_a.length > 0

      StructureDiff.new( structure_to.schema, diff )

    end.compact

  end

  def diff_tables_data

    table_data_to = @verification_to.table_data_versions
    table_data_from = @verification_from.table_data_versions

    table_data_to.each do |table_to|
      
      table_from = table_data_from.select{|t| t.table == table_to.table }.first
      
      table_config = @config['tables'].select{|t| t['name'] == table_to.table }.first

      data_to = table_to.records
      data_from = table_from.records

      indexes_comparate = data_to.columns.map{|column| data_to.columns.index(column) if table_config['comparate'].include? column }.compact

      rows_diff = []

      data_to.rows.each do |row_to|

        rows_matched = data_from.rows.select{|row_from| rows_matched?( row_to, row_from, indexes_comparate ) }

        data_from.rows = data_from.rows - rows_matched

        raise "#{rows_matched.count} rows macthed: #{row_to}" if rows_matched.count > 1

        row_diff_type = RowDiffType::NONE

        row_from = rows_matched[0]

        row_diff_type = RowDiffType::INSERT if row_from.nil?

        row_diff_data = []

        data_to.columns.each_with_index do |column, index|

          next if table_config['except'].include? column

          row_diff_type = RowDiffType::MODIFY if row_from && row_from[index] != row_to[index]

          row_diff_data << ( row_from ? HTMLDiff::DiffBuilder.new(row_from[index].to_s, row_to[index].to_s).build : row_to[index] )

        end

        rows_diff << RowDiff.new( row_diff_type, row_diff_data ) if row_diff_type != RowDiffType::NONE
        
      end

      # Remaining rows
      data_from.rows.each do |row_from|

        row_diff_data = []

        data_from.columns.each_with_index do |column, index|

          next if table_config['except'].include? column

          row_diff_data << row_from[index]

        end

        rows_diff << RowDiff.new( RowDiffType::DELETE, row_diff_data )

      end

      columns_diff = data_to.columns - table_config['except']
      rows_diff.sort_by! {|row| row.data[0] }

      @tables_diff << TableDiff.new( table_to.table, columns_diff, rows_diff ) if rows_diff.length > 0

    end 

    @result = Result::DIFFERENT if @tables_diff.length > 0

  end

  def rows_matched?(row_to, row_from, columns_index)
    columns_index.inject(true){ |result, index| result &&= ( row_to[index] == row_from[index] ) }
  end

  def future # :block:
    thread = Thread.new do
      Thread.current.abort_on_exception = false
      yield
    end
  
    lambda { thread.value }
  end

end
