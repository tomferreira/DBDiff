class ComparisonsController < ApplicationController
  before_filter :authenticate_user!

  def index
    @config = YAML.load_file Rails.root.join('config', 'dbdiff.yml')

    @comparisons = @config['comparisons'].map do |comparison_config|

      database_from = comparison_config['database_from']
      database_to = comparison_config['database_to']

      Comparison.latest( database_from, database_to )

    end.compact

  end

  def show
    @comparison = Comparison.find( params[:id] )

    @structures_diff = @comparison.structures_diff
    @tables_diff = @comparison.tables_diff
  end
end
