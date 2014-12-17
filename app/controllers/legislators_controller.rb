class LegislatorsController < ApplicationController
  before_action :set_legislator, except: [:index, :new]

  # GET /legislators
  def index
    @legislators = Legislator.all.page params[:page]
  end

  # GET /legislators/1
  def show
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_legislator
      @legislator = params[:id] ? Legislator.find(params[:id]) : Legislator.new(legislator_params)
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def legislator_params
      params.require(:legislator).permit()
    end
end