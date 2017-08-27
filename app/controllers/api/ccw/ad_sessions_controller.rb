class Api::Ccw::AdSessionsController < ApplicationController
  respond_to :json
  before_action :set_ad_session, only: [:citizen_score, :show]

  def show
  end

  def index
    limit = params[:limit].blank? ? 10 : params[:limit]
    @ad_sessions = AdSession.includes(:ad).regulations.offset(params[:offset]).limit(limit)
    @ad_sessions_count = AdSession.includes(:ad).regulations.count
    respond_with(@ad_sessions, @ad_sessions_count)
  end

  def citizen_score
    limit = params[:limit].blank? ? 10 : params[:limit]
    ransack_params = {}
    ransack_params[:legislator_committee_legislator_name_cont] = params[:query] if params[:query]
    if params[:party]
      if params[:party] == 'null'
        ransack_params[:legislator_committee_legislator_elections_party_abbreviation_null] = 1
      else
        ransack_params[:legislator_committee_legislator_elections_party_abbreviation_eq] = params[:party].upcase
      end
    end
    if ransack_params.blank?
      @ccw_legislator_data = @ad_session.ccw_legislator_data.includes({legislator_committee: {legislator: {elections: [:party, :ad] }}}).offset(params[:offset]).limit(limit)
      @ccw_legislator_data_count = @ad_session.ccw_legislator_data.count
    else
      @ccw_legislator_data = @ad_session.ccw_legislator_data.includes({legislator_committee: {legislator: {elections: [:party, :ad] }}}).ransack(ransack_params).result(distinct: true)
        .offset(params[:offset]).limit(limit)
      @ccw_legislator_data_count = @ad_session.ccw_legislator_data.ransack(ransack_params).result(distinct: true).count
    end
    @ccw_citizen_score = @ad_session.ccw_citizen_score
    respond_with(@ccw_legislator_data, @ccw_legislator_data_count)
  end

  private

  def set_ad_session
    @ad_session = params[:id] ? AdSession.find(params[:id]) : AdSession.new(ad_session_params)
  end
end