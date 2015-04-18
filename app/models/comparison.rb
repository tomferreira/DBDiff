class Comparison < ActiveRecord::Base
  belongs_to :verification_from, class_name: "Verification", foreign_key: "verification_from_id"
  belongs_to :verification_to, class_name: "Verification", foreign_key: "verification_to_id"
  attr_accessible :result, :structures_diff, :tables_diff
  
  before_save :set_databases

  serialize :tables_diff
  serialize :structures_diff

  def self.latest(database_from, database_to)
    Comparison
      .where( database_from: database_from )
      .where( database_to: database_to )      
      .last 
  end

  def describe
    "#{database_to} vs #{database_from}"
  end

private

  def set_databases
    self.database_from = verification_from.database
    self.database_to = verification_to.database
  end
end
