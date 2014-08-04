require 'differ'

class VerificationsController < ApplicationController
  before_filter :authenticate_user!

  def show
    @verification = Verification.find(params[:id])

    config = YAML.load_file Rails.root.join('config', 'dbdiff.yml')
    @database = config['databases'].select{|database| database['database'] == @verification.database}.first

    @structure_body_infos = @verification.structures.map{|s| s.body_info }

  end

  def diff
    @verification_to = Verification.find(params[:to])
    @verification_from = Verification.find(params[:from])

    differ = Differ.new @verification_to, @verification_from

    @structures_diff = differ.structures_diff
    @tables_diff = differ.tables_diff

  end

end
