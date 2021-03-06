class LegislatorsController < ApplicationController
  before_action :set_legislator, except: [:index, :new, :no_record, :has_records, :search, :result]

  # GET /legislators
  def index
    if params[:format] == "json"
      if params[:query]
        @legislators = Legislator.ransack({name_cont: params[:query]}).result(distinct: true).offset(params[:offset]).limit(params[:limit])
        @legislators_count = Legislator.ransack({name_cont: params[:query]}).result(distinct: true).count
      else
        @legislators = Legislator.offset(params[:offset]).limit(params[:limit])
        @legislators_count = Legislator.all.count
      end
    else
      if params[:ad] and Ad.exists?(id: params[:ad])
        @ad = Ad.find(params[:ad])
        search_params = params[:q].present? ? params[:q].clone : {}
        search_params[:elections_ad_id_eq] = params[:ad]
        @q = Legislator.includes(elections: [:party, :ad]).search(search_params)
      else
        @ad = nil
        params[:q][:elections_ad_id_eq] = nil if params[:q].present? and params[:q][:elections_ad_id_eq].present?
        @q = Legislator.includes(elections: :party).search(params[:q])
      end
      @legislators = @q.result(distinct: true).all
    end
    @parties = Party.all

    set_meta_tags({
      title: '立委列表',
      description: '看看現任立委在國會殿堂的表現吧！',
      keywords: '立法委員,立委,國民黨,民進黨,台聯,親民黨,無黨籍,國會委員',
      og: {
        type: 'website',
        title: '國會立委列表',
        description: '看看現任立委在國會殿堂的表現吧！'
      }
    })

    respond_to do |format|
      format.html
      format.json {render json: {
        status: "success",
        legislators: JSON.parse(@legislators.to_json(
          except: [:description, :now_party_id, :created_at, :updated_at],
          include: {party: {except: [:created_at, :updated_at]}
          })),
        count: @legislators_count},
        callback: params[:callback]
      }
    end
  end

  # GET /legislators/no_record
  def no_record
    if params[:format] == "json"
      if params[:query]
        @legislators = Legislator.ransack({name_cont: params[:query]}).result(distinct: true).has_no_record.offset(params[:offset]).limit(params[:limit])
        @legislators_count = Legislator.ransack({name_cont: params[:query]}).result(distinct: true).has_no_record.length
      else
        @legislators = Legislator.has_no_record.offset(params[:offset]).limit(params[:limit])
        @legislators_count = Legislator.has_no_record.length
      end
    else
      if params[:ad] and Ad.exists?(id: params[:ad])
        @ad = Ad.find(params[:ad])
        search_params = params[:q].present? ? params[:q].clone : {}
        search_params[:elections_ad_id_eq] = params[:ad]
        @q = Legislator.includes(elections: [:party, :ad]).has_no_record.search(search_params)
      else
        @ad = nil
        params[:q][:elections_ad_id_eq] = nil if params[:q].present? and params[:q][:elections_ad_id_eq].present?
        @q = Legislator.includes(elections: [:party, :ad]).has_no_record.search(params[:q])
      end
      @legislators = @q.result(distinct: true).all
    end
    @parties = Party.all

    set_meta_tags({
      title: '立委列表',
      description: '看看現任立委在國會殿堂的表現吧！',
      keywords: '立法委員,立委,國民黨,民進黨,台聯,親民黨,無黨籍,國會委員',
      og: {
        type: 'website',
        title: '國會立委列表',
        description: '看看現任立委在國會殿堂的表現吧！'
      }
    })
    respond_to do |format|
      format.html
      format.json {render json: {
        status: "success",
        legislators: JSON.parse(@legislators.to_json(
          except: [:description, :now_party_id, :created_at, :updated_at],
          include: {party: {except: [:created_at, :updated_at]}
          })),
        count: @legislators_count
        },
        callback: params[:callback]
      }
    end
  end

  # GET /legislators/has_records
  def has_records
    if params[:format] == "json"
      if params[:query]
        @legislators = Legislator.ransack({name_cont: params[:query]}).result(distinct: true).has_records.offset(params[:offset]).limit(params[:limit])
        @legislators_count = Legislator.ransack({name_cont: params[:query]}).result(distinct: true).has_records.length
      else
        @legislators = Legislator.has_records.offset(params[:offset]).limit(params[:limit])
        @legislators_count = Legislator.has_records.length
      end
    else
      if params[:ad] and Ad.exists?(id: params[:ad])
        @ad = Ad.find(params[:ad])
        search_params = params[:q].present? ? params[:q].clone : {}
        search_params[:elections_ad_id_eq] = params[:ad]
        @q = Legislator.includes(elections: [:ad, :party]).has_records.search(search_params)
      else
        @ad = nil
        params[:q][:elections_ad_id_eq] = nil if params[:q].present? and params[:q][:elections_ad_id_eq].present?
        @q = Legislator.includes(elections: [:ad, :party]).has_records.search(params[:q])
      end
      @legislators = @q.result(distinct: true).all
    end
    @parties = Party.all

    set_meta_tags({
      title: '立委列表',
      description: '看看現任立委在國會殿堂的表現吧！',
      keywords: '立法委員,立委,國民黨,民進黨,台聯,親民黨,無黨籍,國會委員',
      og: {
        type: 'website',
        title: '國會立委列表',
        description: '看看現任立委在國會殿堂的表現吧！'
      }
    })

    @jsonld = [
      menu_jsonld,
      generate_page_jsonld("立委列表", "看看現任立委在國會殿堂的表現吧！"),
      generate_people_jsonld(@legislators)
    ]

    respond_to do |format|
      format.html
      format.json {render json: {
        status: "success",
        legislators: JSON.parse(@legislators.to_json(
          except: [:associations_count, :description, :now_party_id, :created_at, :updated_at],
          include: {party: {except: [:created_at, :updated_at]}
          })),
        count: @legislators_count
        },
        callback: params[:callback]
      }
    end
  end

  # GET /legislators/1
  def show
    @videos = @legislator.videos.published.first(5)
    videos = @videos.clone.to_a
    @main_video = videos.shift
    @sub_videos = videos
    @entries = @legislator.entries.published.first(5)
    @interpellations = @legislator.interpellations.published.first(5)

    set_meta_tags({
      title: "#{@legislator.name}調查報告 — #{@legislator.name}立委",
      description: '看看現任立委在國會殿堂的表現吧！',
      keywords: "#{@legislator.name},#{@legislator.name}調查報告",
      og: {
        type: 'profile',
        description: "你知道#{@legislator.name}在國會的表現嗎？這裡是#{@legislator.name}的調查報告。",
        title: "#{@legislator.name}調查報告",
        image: "#{Setting.url.protocol}://#{Setting.url.host}/images/legislators/160x214/#{@legislator.image}"
      }
    })

    @jsonld = [
      menu_jsonld,
      generate_page_jsonld("#{@legislator.name}調查報告 — #{@legislator.name}立委", '看看現任立委在國會殿堂的表現吧！'),
      generate_person_jsonld(@legislator)      
    ]

    unless @videos.blank?
      @jsonld << generate_videos_jsonld(@videos)
    end

    respond_to do |format|
      format.html
      format.json {render json: {
        status: "success",
        legislator: JSON.parse(@legislator.to_json(
        except: [:description, :now_party_id, :created_at, :updated_at],
        include: {
          party: {except: [:created_at, :updated_at]},
          elections: {
            except: [:created_at, :updated_at],
            include: {ad: {except: [:created_at, :updated_at]}
            }
          },
          interpellations: {}, entries:{}, videos:{}
        }))},
        callback: params[:callback]
      }
    end
  end

  # GET /legislators/1/entries
  def entries
    if params[:format] == "json"
      if params[:query]
        @entries = @legislator.entries.ransack({title_or_content_cont: params[:query]}).result(distinct: true)
          .published.offset(params[:offset]).limit(params[:limit])
        @entries_count = @legislator.entries.ransack({title_or_content_cont: params[:query]}).result(distinct: true)
          .published.count
      else
        @entries = @legislator.entries.published.offset(params[:offset]).limit(params[:limit])
        @entries_count = @legislator.entries.published.count
      end
    else
      @entries = @legislator.entries.published.page(params[:page])
    end
    entries = @entries.clone.to_a
    @main_entry = entries.shift
    @sub_entries = entries

    set_meta_tags({
      title: "#{@legislator.name}新聞列表 — #{@legislator.name}立委",
      description: @main_entry.try(:title),
      keywords: "#{@legislator.name},#{@legislator.name}新聞調查",
      og: {
        type: 'article',
        description: @main_entry.try(:title),
        title: "#{@legislator.name}新聞調查報告",
        image: "#{Setting.url.protocol}://#{Setting.url.host}/images/legislators/160x214/#{@legislator.image}"
      }
    })
    respond_to do |format|
      format.html
      format.json { render json: {
          status: "success",
          entries: JSON.parse(@entries.to_json({except: [:user_id, :user_ip, :published]})),
          count: @legislator.entries.published.count
        },
        callback: params[:callback]
      }
    end
  end

  # GET /legislators/1/interpellations
  def interpellations
    if params[:format] == "json"
      if params[:query]
        @interpellations = @legislator.interpellations.ransack({title_or_content_or_meeting_description_cont: params[:query]}).result(distinct: true)
          .published.offset(params[:offset]).limit(params[:limit])
        @interpellations_count = @legislator.interpellations.ransack({title_or_content_or_meeting_description_cont: params[:query]}).result(distinct: true)
          .published.count
      else
        @interpellations = @legislator.interpellations.published.offset(params[:offset]).limit(params[:limit])
        @interpellations_count = @legislator.interpellations.published.count
      end
    else
      @interpellations = @legislator.interpellations.published.page(params[:page])
    end
    interpellations = @interpellations.clone.to_a
    @main_interpellation = interpellations.shift
    @sub_interpellations = interpellations

    set_meta_tags({
      title: "#{@legislator.name}質詢列表 — #{@legislator.name}立委",
      description: @main_interpellation.try(:title),
      keywords: "#{@legislator.name},#{@legislator.name}質詢調查",
      og: {
        type: 'article',
        description: @main_interpellation.try(:title),
        title: "#{@legislator.name}質詢調查報告",
        image: "#{Setting.url.protocol}://#{Setting.url.host}/images/legislators/160x214/#{@legislator.image}"
      }
    })

    respond_to do |format|
      format.html
      format.json { render json: {
          status: "success",
          interpellations: JSON.parse(
            @interpellations.to_json({include: {
              ad_session: { except: [:created_at, :updated_at] },
              ad: { except: [:created_at, :updated_at] },
              committee: { except: [:created_at, :updated_at] }
            }, except: [:user_id, :user_ip, :published]})
          ),
          count: @interpellations_count
        },
        callback: params[:callback]
      }
    end

  end

  # GET /legislators/1/videos
  def videos
    if params[:format] == "json"
      if params[:query]
        @videos = @legislator.videos.ransack({title_or_content_or_meeting_description_cont: params[:query]}).result(distinct: true)
          .published.offset(params[:offset]).limit(params[:limit])
        @videos_count = @legislator.videos.ransack({title_or_content_or_meeting_description_cont: params[:query]}).result(distinct: true)
          .published.count
      else
        @videos = @legislator.videos.published.offset(params[:offset]).limit(params[:limit])
        @videos_count = @legislator.videos.published.count
      end
    else
      @videos = @legislator.videos.published.page(params[:page])
    end
    videos = @videos.clone.to_a
    @main_video = videos.shift
    @sub_videos = videos

    set_meta_tags({
      title: "#{@legislator.name}影片列表 — #{@legislator.name}立委",
      description: @main_video.try(:title),
      keywords: "#{@legislator.name},#{@legislator.name}影片調查",
      og: {
        type: 'video.tv_show',
        description: @main_video.try(:title),
        title: "#{@legislator.name}影片調查報告",
        image: "#{Setting.url.protocol}://#{Setting.url.host}/images/legislators/160x214/#{@legislator.image}"
      }
    })

    @jsonld = [
      menu_jsonld,
      generate_page_jsonld("#{@legislator.name}影片列表 — #{@legislator.name}立委", @main_video.try(:title)),
      generate_person_jsonld(@legislator),
      generate_videos_jsonld(@videos)
    ]

    respond_to do |format|
      format.html
      format.json { render json: {
          status: "success",
          videos: JSON.parse(
            @videos.to_json({include: {
              ad_session: { except: [:created_at, :updated_at] },
              ad: { except: [:created_at, :updated_at] },
              committee: { except: [:created_at, :updated_at] }
            }, except: [:user_id, :user_ip, :published]})
          ),
          count: @videos_count
        },
        callback: params[:callback]
      }
    end
  end

  # GET /legislators/1/votes
  def votes
    page = params[:page]
    decision = params[:decision]
    ad = params[:ad].to_i
    if @legislator.ads.last.id < ad or ad < @legislator.ads.first.id
      @ad = @legislator.ads.last
    else
      @ad = @legislator.ads.find(ad)
    end
    @ads = @legislator.ads
    unless ["agree", "disagree", "abstain", "notvote"].include?(decision)
      decision = nil
      params[:decision] = nil
    end
    @votes, @current_page, @pages, @status = parse_vote_guide_voter_api(@legislator.id, @ad.id, page, decision)
    @decision = decision
    flash.now[:alert] = "網站解析失敗，請稍後嘗試。" unless @status

    set_meta_tags({
      title: "#{@legislator.name}投票表決紀錄",
      description: "你知道#{@legislator.name}贊成反對那些提案嗎？請看#{@legislator.name}的投票表決紀錄。",
      keywords: "#{@legislator.name},#{@legislator.name}投票表決紀錄",
      og: {
        type: 'article',
        description: "你知道#{@legislator.name}贊成反對那些提案嗎？請看#{@legislator.name}的投票表決紀錄。",
        title: "#{@legislator.name}投票表決紀錄",
        image: "#{Setting.url.protocol}://#{Setting.url.host}/images/legislators/160x214/#{@legislator.image}",
        site_name: "國會調查兵團"
      }
    })

  end

  # GET /legislators/1/bills
  def bills
    page = params[:page]
    ad = params[:ad].to_i
    if @legislator.ads.last.id < ad or ad < @legislator.ads.first.id
      @ad = @legislator.ads.last
    else
      @ad = @legislator.ads.find(ad)
    end
    @ads = @legislator.ads
    @bills, @current_page, @pages, @count, @status = parse_vote_guide_biller_api(@legislator.id, @ad.id, page)
    flash.now[:alert] = "網站解析失敗，請稍後嘗試。" unless @status

    set_meta_tags({
      title: "#{@legislator.name}法律修正案紀錄",
      description: "你知道#{@legislator.name}提過哪些法律修正案嗎？請看#{@legislator.name}的法律修正案紀錄。",
      keywords: "#{@legislator.name},#{@legislator.name}法律修正案紀錄",
      og: {
        type: 'article',
        description: "你知道#{@legislator.name}提過哪些法律修正案嗎？請看#{@legislator.name}的法律修正案紀錄。",
        title: "#{@legislator.name}法律修正案紀錄",
        image: "#{Setting.url.protocol}://#{Setting.url.host}/images/legislators/160x214/#{@legislator.image}",
        site_name: "國會調查兵團"
      }
    })
  end

  # GET /legislators/1/candidate
  def candidate
    ad = params[:ad].to_i
    if @legislator.ads.last.id < ad or ad < @legislator.ads.first.id
      @ad = @legislator.ads.last
    else
      @ad = @legislator.ads.find(ad)
    end

    @ads = @legislator.ads
    @constituency = @legislator.get_election(@ad.id).try(:constituency)
    if @constituency == "全國不分區"
      @candidate, @status = {}, false
    else
      @candidate, @status = parse_vote_guide_candidate(@legislator.id, @ad.id)
      @constituency = @legislator.get_election(@ad.id).try(:constituency)
      flash.now[:alert] = "網站解析失敗，請稍後嘗試。" unless @status
    end

    set_meta_tags({
      title: "#{@legislator.name}政治獻金紀錄",
      description: "你知道#{@legislator.name}的政治獻金收入與支出狀況嗎？請看#{@legislator.name}的政治獻金紀錄。",
      keywords: "#{@legislator.name},#{@legislator.name}政治獻金紀錄,政治獻金",
      og: {
        type: 'article',
        description: "你知道#{@legislator.name}的政治獻金收入與支出狀況嗎？請看#{@legislator.name}的政治獻金紀錄。",
        title: "#{@legislator.name}政治獻金紀錄",
        image: "#{Setting.url.protocol}://#{Setting.url.host}/images/legislators/160x214/#{@legislator.image}",
        site_name: "國會調查兵團"
      }
    })
  end

  # GET /legislators/1/ccw
  def ccw
    ad_session_id = params[:ad_session].to_i
    @ad_sessions = @legislator.ad_sessions.has_ccw_data
    ad_session_ids = @ad_sessions.map { |a| a.id }
    if ad_session_ids.include? ad_session_id
      @ad_session = AdSession.find(ad_session_id)
    else
      @ad_session = @legislator.ad_sessions.has_ccw_data.last
    end
    if @ad_session.blank?
      @status = false
      flash.now[:alert] = "目前尚未輸入相關資料"
      return
    end
    @ccw_legislator_datum = @legislator.get_session_ccw_data(@ad_session.id).first
    @sc_committee = @legislator.get_session_committee(@ad_session.id, 'sc').first
    @yc_committee = Committee.find(19)
    @sc_committee_datum = @sc_committee.ccw_committee_data.where(ad_session_id: @ad_session.id).first
    @yc_committee_datum = @yc_committee.ccw_committee_data.where(ad_session_id: @ad_session.id).first
    @ccw_citizen_score = @ad_session.ccw_citizen_score
    if @sc_committee_datum.blank? or @yc_committee_datum.blank? or @ccw_citizen_score.blank? or @ccw_legislator_datum.blank?
      @status = false
      flash.now[:alert] = "目前尚未輸入相關資料"
    else
      @status = true
    end

    set_meta_tags({
      title: "#{@legislator.name}公督盟#{@ad_session.ad.name}#{@ad_session.name}評鑑",
      description: "你知道#{@legislator.name}在公督盟立委評鑑的評價嗎？請看#{@legislator.name}#{@ad_session.ad.name}#{@ad_session.name}公督盟評鑑。",
      keywords: "#{@legislator.name},#{@legislator.name}公督盟評鑑",
      og: {
        type: 'article',
        description: "你知道#{@legislator.name}在公督盟立委評鑑的評價嗎？請看#{@legislator.name}#{@ad_session.ad.name}#{@ad_session.name}公督盟評鑑。",
        title: "#{@legislator.name}公督盟#{@ad_session.ad.name}#{@ad_session.name}評鑑",
        image: "#{Setting.url.protocol}://#{Setting.url.host}/images/legislators/160x214/#{@legislator.image}",
        site_name: "國會調查兵團"
      }
    })
  end

  # GET /legislators/search
  def search
    @q = Election.search(params[:q])

    set_meta_tags({
      title: "找立委",
      description: "你知道現任立委是誰嗎？想看看各黨立委有誰嗎？趕快來查查他們在立法院的表現吧！",
      keywords: "找立委,區域立委,不分區立委",
      og: {
        type: 'article',
        description: "你知道現任立委是誰嗎？想看看各黨立委有誰嗎？趕快來查查他們在立法院的表現吧！",
        title: "找立委",
        site_name: "國會調查兵團"
      }
    })
  end

  # GET /legislators/1/result
  def result
    @q = Election.includes(:ad, :legislator, :party, :districts).search(params[:q])
    @ad_id_eq = params[:q] ? params[:q][:ad_id_eq] : nil
    @county_id_eq = params[:q] ? params[:q][:county_id_eq] : nil
    @party_id_eq = params[:q] ? params[:q][:party_id_or_legislator_now_party_id_eq] : nil
    if params[:q] and \
        params[:q][:ad_id_eq].blank? and \
        params[:q][:county_id_eq].blank? and \
        params[:q][:party_id_or_legislator_now_party_id_eq].blank? and \
        params[:q][:legislator_name_cont].blank?
      params[:commit] = nil
    end
    if params[:commit].blank?
      @title = ""
      @elections = []
    else
      @title = "立委"
      unless params[:q][:party_id_or_legislator_now_party_id_eq].blank?
        party = Party.find(params[:q][:party_id_or_legislator_now_party_id_eq])
        if party
          @title = party.name + @title
        end
      end
      unless params[:q][:county_id_eq].blank?
        county = County.find(params[:q][:county_id_eq])
        if county
          @title = county.name + @title
        end
      end
      unless params[:q][:ad_id_eq].blank?
        ad = Ad.find(params[:q][:ad_id_eq])
        if ad
          @title = ad.name + @title
        end
      end
      @elections = @q.result(distinct: true).all
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_legislator
    @legislator = params[:id] ? Legislator.includes({elections: [:ad, :party]}).find(params[:id]) : Legislator.new(legislator_params)
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def legislator_params
    params.require(:legislator).permit()
  end

  def parse_vote_guide_voter_api(legislator_id, ad, page = nil, decision = nil)
    begin
      params = {}
      legislator_term_data = get_vote_guide_legislator_term_data(legislator_id, ad)
      params[:legislator] = legislator_term_data['id']
      unless page.blank?
        params[:page] = page
      end
      unless decision.blank?
        if decision == 'agree'
          params[:decision] = 1
        elsif decision == 'abstain'
          params[:decision] = 0
        elsif decision == 'disagree'
          params[:decision] = -1
        elsif decision == 'notvote'
          params[:not_voting] = 1
        end
      end
      votes_url = "http://vote.ly.g0v.tw/api/legislator_vote/?" + params.to_query
      votes_json = JSON.parse(get_cached_page(votes_url))
      current_page, pages = parse_page_info(votes_json["count"], page)
      results = votes_json['results']
      # need to parse the vote
      votes = []
      results.each do |result|
        vote = {}
        if result["decision"] == 1
          vote[:decision] = "agree"
        elsif result["decision"] == 0
          vote[:decision] = "abstain"
        elsif result["decision"] == -1
          vote[:decision] = "disagree"
        elsif result["decision"] == nil
          vote[:decision] = "notvote"
        else
          vote[:decision] = "unknown"
        end
        vote_url = result["vote"]
        vote_json = JSON.parse(get_cached_page(vote_url))
        if vote_json["result"] == "Passed"
          vote[:result] = "passed"
        elsif vote_json["result"] == "Not Passed"
          vote[:result] = "notpassed"
        else
          vote[:result] = "unknown"
        end
        vote[:reason] = vote_json["content"].strip.gsub("　", "")
        sitting_id = vote_json["sitting_id"]
        sitting_url = "http://vote.ly.g0v.tw/api/sittings/#{sitting_id}/"
        sitting_json = JSON.parse(get_cached_page(sitting_url))
        vote[:date] = sitting_json["date"]
        vote[:link] = "http://vote.ly.g0v.tw/vote/#{vote_json["uid"]}/"
        votes << vote
      end
      return votes, current_page, pages, true
    rescue
      return [], 1, [], false
    end
  end

  def parse_vote_guide_voter(legislator_id, ad, page = nil, decision = nil)
    params = {}
    unless page.blank?
      params[:page] = page
      current_page = page.to_i
    else
      current_page = 1
    end
    unless decision.blank?
      params[:decision] = decision
    end
    if params.any?
      url = "http://vote.ly.g0v.tw/legislator/voter/#{legislator_id}/#{ad}/?" + params.to_query
    else
      url = "http://vote.ly.g0v.tw/legislator/voter/#{legislator_id}/#{ad}/"
    end
    begin
      pages = []
      votes = []
      html = Nokogiri::HTML(get_cached_page(url))
      info_section = html.css('div.span9')[0]
      pagination_section = info_section.css('div.pagination')[0]
      unless pagination_section.blank?
        pagination_section.css('li').each do | li |
          pages << li.text.to_i if li.text.match(/^\d+$/)
        end
      else
        pages = []
      end
      vote_section = info_section.css('tbody')[0]
      vote_section.css('tr').each do | tr |
        vote = {}
        tds = tr.css('td')
        vote[:ad] = tds[0].text.strip
        action = tds[1].text.strip
        if action == '贊成'
          vote[:decision] = 'agree'
        elsif action == '棄權'
          vote[:decision] = 'abstain'
        elsif action == '反對'
          vote[:decision] = 'disagree'
        elsif action == '沒有投票'
          vote[:decision] = 'notvote'
        else
          vote[:decision] = 'unknown'
        end
        result = tds[2].text.strip
        if result == '通過'
          vote[:result] = 'passed'
        elsif result == '不通過'
          vote[:result] = 'notpassed'
        else
          vote[:result] = 'unknown'
        end
        vote[:date] = tds[3].text.strip
        vote[:link] = "http://vote.ly.g0v.tw" + tds[4].css('a').attr('href').value
        vote[:reason] = tds[4].text.strip.split("\n")[-1].strip.gsub("　", "")
        votes << vote
      end
      return votes, current_page, pages, true
    rescue
      return [], current_page, [], false
    end
  end

  def parse_vote_guide_biller_api(legislator_id, ad, page = nil)
    begin
      params = {}
      legislator_term_data = get_vote_guide_legislator_term_data(legislator_id, ad)
      params[:legislator] = legislator_term_data['id']
      unless page.blank?
        params[:page] = page
      end
      bills_url = "http://vote.ly.g0v.tw/api/legislator_bill/?" + params.to_query
      bills_json = JSON.parse(get_cached_page(bills_url))
      current_page, pages = parse_page_info(bills_json["count"], page)
      count = bills_json["count"]
      results = bills_json['results']
      bills = []
      results.each do |result|
        bill = {}
        bill_url = result["bill"]
        bill_json = JSON.parse(get_cached_page(bill_url))
        bill[:reason] = bill_json["data"]["motions"][-1]["議案內容"]
        bill[:title] = bill_json["data"]["提案名稱"]
        bill[:id] = bill_json["uid"]
        bill[:link] = bill_json["data"]["links"]["審議進度"]
        bill[:progress] = bill_json["data"]["進度"]
        bill[:warning] = nil
        bills << bill
      end
      return bills, current_page, pages, count, true
    rescue
      return [], 1, [], 0, false
    end
  end

  def parse_vote_guide_biller(legislator_id, ad, page = nil)
    params = {}
    unless page.blank?
      params[:page] = page
      current_page = page.to_i
      url = "http://vote.ly.g0v.tw/legislator/biller/#{legislator_id}/#{ad}/?" + params.to_query
    else
      current_page = 1
      url = "http://vote.ly.g0v.tw/legislator/biller/#{legislator_id}/#{ad}/"
    end
    begin
      pages = []
      bills = []
      count = ""
      html = Nokogiri::HTML(get_cached_page(url))
      info_section = html.css('div.span9')[0]
      count_section = info_section.css('.well .lead')
      count = count_section.text.split('：')[-1].split("個")[0]
      pagination_section = info_section.css('div.pagination')[0]
      unless pagination_section.blank?
        pagination_section.css('li').each do | li |
          pages << li.text.to_i if li.text.match(/^\d+$/)
        end
      else
        pages = []
      end
      bill_section = info_section.css('ul.media-list')[0]
      bill_section.css('li.media').each do | li |
        bill = {}
        bill[:reason] = li.css('div.media-heading').text.strip
        progress = []
        li.css('blockquote').text.split("\n").each do |text|
          text = text.strip
          progress << text unless text.blank?
        end
        if li.css('font.lead').any?
          bill[:warning] = li.css('font.lead').text
          progress = progress[1..-1]
        else
          bill[:warning] = nil
        end
        bill[:progress] = progress
        bill[:link] = li.css('a').attr('href').value
        bill[:id] = bill[:link].split('/')[-1]
        ly_g0v_url = "http://api.ly.g0v.tw/v0/collections/bills/#{bill[:id]}"
        ly_g0v_json = JSON.parse(get_cached_page(ly_g0v_url))
        bill[:title] = ly_g0v_json['summary']
        # bill[:reason] = ly_g0v_json['abstract']
        bills << bill
      end
      return bills, current_page, pages, count, true
    rescue
      return [], current_page, [], count, false
    end
  end

  def parse_vote_guide_candidate(legislator_id, ad)
    begin
      legislator_term_data = get_vote_guide_legislator_term_data(legislator_id, ad)
      unless legislator_term_data.blank?
        candidate_url = legislator_term_data["elected_candidate"]
        unless candidate_url.blank?
          candidate_json = JSON.parse(get_cached_page(candidate_url))
          if candidate_json.has_key? "politicalcontributions" and not candidate_json["politicalcontributions"].blank?
            return candidate_json["politicalcontributions"], true
          end
        end
      end
      return {}, false
    rescue
      return {}, false
    end
  end

  def get_vote_guide_legislator_term_data(legislator_id, ad)
    legislator_term_url = "http://vote.ly.g0v.tw/api/legislator_terms/?format=json&ad=#{ad}&legislator=#{legislator_id}"
    legislator_term_json = JSON.parse(get_cached_page(legislator_term_url))
    if legislator_term_json["results"].any?
      return legislator_term_json["results"][0]
    else
      return nil
    end
  end
end
