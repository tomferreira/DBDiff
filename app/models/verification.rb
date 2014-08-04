class Verification < ActiveRecord::Base
  has_many :structures
  has_many :table_data_versions
  attr_accessible :database, :date, :duration
end
