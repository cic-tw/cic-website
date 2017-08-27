class Api::LegislatorsController < ApplicationController
  respond_to :json
  before_action :set_legislator, except: [:index, :no_record, :has_records]

  def index
    limit = params[:limit].blank? ? 10 : params[:limit]
    ransack_params = {}
    ransack_params[:name_cont] = params[:query] if params[:query]
    if params[:in_office]
      if params[:in_office] == 'true'
        ransack_params[:in_office_eq] = true
      elsif params[:in_office] == 'false'
        ransack_params[:in_office_eq] = false
      end
    end
    ransack_params[:elections_ad_id_eq] = params[:ad] if params[:ad]
    if params[:party]
      if params[:party] == 'null'
        ransack_params[:elections_party_abbreviation_null] = 1
      else
        ransack_params[:elections_party_abbreviation_eq] = params[:party].upcase
      end
    end
    if ransack_params.blank?
      @legislators = Legislator.includes({elections: [:party, :ad], legislator_committees: [:committee, {ad_session: :ad}]}).offset(params[:offset]).limit(limit)
      @legislators_count = Legislator.count
    else
      @legislators = Legislator.includes({elections: [:party, :ad], legislator_committees: [:committee, {ad_session: :ad}]}).ransack(ransack_params).result(distinct: true)
        .offset(params[:offset]).limit(limit)
      @legislators_count = Legislator.ransack(ransack_params).result(distinct: true).count
    end
    respond_with(@legislators, @legislators_count)
  end

  def no_record
    limit = params[:limit].blank? ? 10 : params[:limit]
    ransack_params = {}
    ransack_params[:name_cont] = params[:query] if params[:query]
    if params[:in_office]
      if params[:in_office] == 'true'
        ransack_params[:in_office_eq] = true
      elsif params[:in_office] == 'false'
        ransack_params[:in_office_eq] = false
      end
    end
    ransack_params[:elections_ad_id_eq] = params[:ad] if params[:ad]
    if params[:party]
      if params[:party] == 'null'
        ransack_params[:elections_party_abbreviation_null] = 1
      else
        ransack_params[:elections_party_abbreviation_eq] = params[:party].upcase
      end
    end
    if ransack_params.blank?
      @legislators = Legislator.includes({elections: [:party, :ad], legislator_committees: [:committee, {ad_session: :ad}]}).has_no_record.offset(params[:offset]).limit(limit)
      @legislators_count = Legislator.has_no_record.length
    else
      @legislators = Legislator.includes({elections: [:party, :ad], legislator_committees: [:committee, {ad_session: :ad}]}).ransack(ransack_params).result(distinct: true).has_no_record
        .offset(params[:offset]).limit(limit)
      @legislators_count = Legislator.ransack(ransack_params).result(distinct: true).has_no_record.length
    end
    respond_with(@legislators, @legislators_count)
  end

  def has_records
    limit = params[:limit].blank? ? 10 : params[:limit]
    ransack_params = {}
    ransack_params[:name_cont] = params[:query] if params[:query]
    if params[:in_office]
      if params[:in_office] == 'true'
        ransack_params[:in_office_eq] = true
      elsif params[:in_office] == 'false'
        ransack_params[:in_office_eq] = false
      end
    end
    ransack_params[:elections_ad_id_eq] = params[:ad] if params[:ad]
    if params[:party]
      if params[:party] == 'null'
        ransack_params[:elections_party_abbreviation_null] = 1
      else
        ransack_params[:elections_party_abbreviation_eq] = params[:party].upcase
      end
    end
    if ransack_params.blank?
      @legislators = Legislator.includes({elections: [:party, :ad], legislator_committees: [:committee, {ad_session: :ad}]}).has_records.offset(params[:offset]).limit(limit)
      @legislators_count = Legislator.has_records.length
    else
      @legislators = Legislator.includes({elections: [:party, :ad], legislator_committees: [:committee, {ad_session: :ad}]}).ransack(ransack_params).result(distinct: true).has_records
        .offset(params[:offset]).limit(limit)
      @legislators_count = Legislator.ransack(ransack_params).result(distinct: true).has_records.length
    end
    respond_with(@legislators, @legislators_count)
  end

  def show
    @legislator = Legislator.includes({elections: [:party, :ad], legislator_committees: [:committee, {ad_session: :ad}]}).find(params[:id])
    respond_with(@legislator)
  end

  def entries
    limit = params[:limit].blank? ? 10 : params[:limit]
    ransack_params = {}
    ransack_params[:title_or_content_cont] = params[:query] if params[:query]
    if ransack_params.blank?
      @entries = @legislator.entries.includes(legislators: :elections).published.offset(params[:offset]).limit(limit)
      @entries_count = @legislator.entries.published.count
    else
      @entries = @legislator.entries.includes(legislators: :elections).ransack(ransack_params).result(distinct: true)
        .published.offset(params[:offset]).limit(limit)
      @entries_count = @legislator.entries.ransack({title_or_content_cont: params[:query]}).result(distinct: true)
        .published.count
    end
    respond_with(@entries, @entries_count)
  end

  def interpellations
    limit = params[:limit].blank? ? 10 : params[:limit]
    ransack_params = {}
    ransack_params[:title_or_content_or_meeting_description_cont] = params[:query] if params[:query]
    if ransack_params.blank?
      @interpellations = @legislator.interpellations.includes(:committee, ad_session: :ad, legislators: :elections).published.offset(params[:offset]).limit(limit)
      @interpellations_count = @legislator.interpellations.published.count
    else
      @interpellations = @legislator.interpellations.includes(:committee, :ad_session, legislators: :elections).ransack(ransack_params).result(distinct: true)
        .published.offset(params[:offset]).limit(limit)
      @interpellations_count = @legislator.interpellations.ransack(ransack_params).result(distinct: true)
        .published.count
    end
    respond_with(@interpellations, @interpellations_count)
  end

  def videos
    limit = params[:limit].blank? ? 10 : params[:limit]
    ransack_params = {}
    ransack_params[:title_or_content_or_meeting_description_cont] = params[:query] if params[:query]
    if ransack_params.blank?
      @videos = @legislator.videos.includes(:committee, ad_session: :ad, legislators: :elections).published.offset(params[:offset]).limit(limit)
      @videos_count = @legislator.videos.published.count
    else
      @videos = @legislator.videos.includes(:committee, ad_session: :ad, legislators: :elections).ransack(ransack_params).result(distinct: true)
        .published.offset(params[:offset]).limit(limit)
      @videos_count = @legislator.videos.ransack({title_or_content_or_meeting_description_cont: params[:query]}).result(distinct: true)
        .published.count
    end
    respond_with(@videos, @videos_count)
  end

  private

  def set_legislator
    @legislator = params[:id] ? Legislator.find(params[:id]) : Legislator.new(legislator_params)
  end
end