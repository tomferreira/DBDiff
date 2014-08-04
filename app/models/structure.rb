class Structure < ActiveRecord::Base
  belongs_to :verification
  attr_accessible :dump_filename, :schema

  default_scope order('schema ASC')

  StructureBodyInfo = Struct.new(:success, :body, :message)

  def body_info
    result = StructureBodyInfo.new

    result.body = File.open( self[:dump_filename] ).read
    result.success = true
    result

  rescue => e
    result.success = false
    result.message = e.message
    result

  end


end
