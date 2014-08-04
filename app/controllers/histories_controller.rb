class HistoriesController < ApplicationController
  before_filter :authenticate_user!

  def index
    config = YAML.load_file Rails.root.join('config', 'dbdiff.yml')
    @databases = config['databases']
  end

  def show
    config = YAML.load_file Rails.root.join('config', 'dbdiff.yml')
    @database = config['databases'].select{|database| database['database'] == params[:id]}.first

    @verifications = Verification.where( :database => params[:id] ).order('date DESC')

  end


end
