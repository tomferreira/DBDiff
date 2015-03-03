require 'csv'

class TableDataVersion < ActiveRecord::Base
  belongs_to :verification
  attr_accessible :records, :table

  Records = Struct.new(:columns, :rows)

  def records=(records)

    self[:data] = CSV.generate(:row_sep => :auto, :col_sep => ";") do |csv|
      csv << records.columns

      records.rows.each do |row|
        csv << row
      end
    end

  end

  def records
    
    parse = CSV.parse(self[:data], :row_sep => :auto, :col_sep => ";")

    Records.new(parse.first, parse[1..-1])

  end
end
