class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session, unless: -> { request.format.json? }

  before_action :configure_devise_permitted_parameters, if: :devise_controller?

  def append_info_to_payload(payload)
    super
    payload[:request_id] = request.uuid
    payload[:user_id] = current_user.id if current_user
    if request.env['HTTP_CF_CONNECTING_IP']
      payload[:ip] = request.env['HTTP_CF_CONNECTING_IP']
    elsif request.env["HTTP_X_FORWARDED_FOR"]
      payload[:ip] = request.env["HTTP_X_FORWARDED_FOR"]
    else
      payload[:ip] = request.env['REMOTE_ADDR']
    end
  end

  protected

  def configure_devise_permitted_parameters
    registration_params = [:name, :email, :password, :password_confirmation, :agreement]

    if params[:action] == 'create'
      devise_parameter_sanitizer.permit(:sign_up) do |user|
        user.permit(registration_params)
      end
    end
  end

  def not_found
    raise ActionController::RoutingError.new('Not Found')
  end

  private

  def require_admin
    unless current_user.admin?
      redirect_back(fallback_location: root_path)
    end
  end

  def get_page(url)
    response = HTTParty.get(url)
    if response.code == 200
      return response.body
    else
      return false
    end
  end

  def get_cached_page(url, day = 7)
    if url.blank?
      return nil
    end
    if $redis.connected?
      page_content = $redis.get(url)
      unless page_content
        page_content = get_page(url)
        if page_content
          $redis.set(url, page_content)
          $redis.expire(url, day.days.to_i)
        end
      end
    else
      page_content = get_page(url)
    end
    return page_content
  end

  def parse_page_info(count, current_page = 1, per = 10)
    current_page = current_page.to_i
    count = count.to_i
    per = per.to_i
    total_page = (count / per) + 1
    if current_page < 1
      current_page = 1
    elsif current_page > total_page
      current_page = total_page
    end
    offset = (current_page - 1) * per
    low_pages = [1, 2, 3, 4]
    high_pages = [(total_page - 3), (total_page - 2), (total_page - 1), total_page]
    current_pages = [(current_page - 3), (current_page - 2), (current_page - 1), current_page, (current_page + 1), (current_page + 2), (current_page + 3)]
    results = low_pages + current_pages + high_pages
    results = results.uniq
    results.sort!
    results.select! { |x| 1 <= x and x <=  total_page}
    return current_page, results
  end

  def menu_jsonld
    return {
     "@context": "http://schema.org",
     "@type": "ItemList",
     itemListElement:[
        {
          position: 1,
          "@type": "WebPage",
          name: "首頁",
          url:"https://cic.tw"
        },
        {
          position: 2,
          "@type": "WebPage",
          name: "最新調查",
          url: "https://cic.tw/recent"
        },
        {
          position: 3,
          "@type": "WebPage",
          name: "回報立委資訊",
          url: "https://cic.tw/report"
        },
        {
          position: 4,
          "@type": "WebPage",
          name: "加入兵團",
          url: "https://cic.tw/users/sign_up"
        },
        {
          position: 5,
          "@type": "WebPage",
          name: "登入",
          url: "https://cic.tw/users/sign_in"
        },
        {
          position: 6,
          "@type": "WebPage",
          name: "兵團計畫說明",
          url: "https://cic.tw/about"
        },
        {
          position: 7,
          "@type": "WebPage",
          name: "贊助兵團",
          url: "http://shop.cic.tw/"
        }
      ]
    }
  end

  def generate_page_jsonld(title, description)
    return {
      "@context": "http://schema.org",
      "@type": "WebPage",
      name: title,
      description: description,
      url: request.url,
      publisher: "國會調查兵團"
    }
  end

  def generate_person_jsonld(legislator)
    return {
      "@context": "http://schema.org/",
      "@type": "Person",
      name: legislator.name,
      image: "https://cic.tw/legislators/#{legislator.id}"
    }
  end 

  def generate_people_jsonld(legislators)
    jsonld = {
      "@context": "http://schema.org/",
      "@type": "DataCatalog",
      character:[]
    }

    legislators.each do |legislator|
      jsonld[:character] << {
        "@type": "Person",
        name: legislator.name,
        url: "https://cic.tw/legislators/#{legislator.id}",
        affiliation: legislator.party.name
      }
    end
    return jsonld
  end

  def generate_video_jsonld(video)
    return {
      "@context": "http://schema.org",
      "@type": "VideoObject",
      name: "#{video.legislators.first.name} － #{video.title}",
      description: video.title,
      embedUrl: "https://www.youtube.com/embed/#{@video.youtube_id}",
      thumbnailUrl: "https://cic.tw#{video.image}",
      uploadDate: "video.created_at.strftime('%Y%m%d')"
    }
  end

  def generate_videos_jsonld(videos)
    jsonld = {
      "@context": "http://schema.org",
      "@type": "ItemList",
      itemListElement: []
    }
    videos.each do |video|
      jsonld[:itemListElement] << {
        "@type": "VideoObject",
        description: video.title,
        name: "#{video.legislators.first.name} － #{video.title}",
        thumbnailUrl: "https://cic.tw#{video.image}",
        uploadDate: "video.created_at.strftime('%Y%m%d')"
      }
    end
    return jsonld
  end
end
