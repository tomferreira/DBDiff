class Comparison < ActiveRecord::Base
  belongs_to :verification_from, class_name: "Verification", foreign_key: "verification_from_id"
  belongs_to :verification_to, class_name: "Verification", foreign_key: "verification_to_id"
  attr_accessible :result, :structures_diff, :tables_diff
  
  serialize :tables_diff
  serialize :structures_diff

  def self.latest(database_from, database_to)
    Comparison
      .joins(:verification_to, :verification_from)
      .where( verifications: {database: database_to}, verification_froms_comparisons: {database: database_from} ).last 
  end

  def describe
    "#{verification_to.database} vs #{verification_from.database}"
  end
end
