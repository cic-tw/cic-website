class AdminsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin

  def index
    @this_month = Date.today.beginning_of_month
    @last_month = @this_month - 1.month
  end

  def entries
    @keyword = params[:keyword] ? Keyword.find(params[:keyword]) : nil
    if @keyword
      @entries = @keyword.entries.page(params[:page])
    else
      @entries = Entry.all.page(params[:page])
    end
  end

  def interpellations
    @keyword = params[:keyword] ? Keyword.find(params[:keyword]) : nil
    if @keyword
      @interpellations = @keyword.interpellations.page(params[:page])
    else
      @interpellations = Interpellation.all.page(params[:page])
    end
  end

  def videos
    @keyword = params[:keyword] ? Keyword.find(params[:keyword]) : nil
    if @keyword
      @videos = @keyword.videos.page(params[:page])
    else
      @videos = Video.all.page(params[:page])
    end
  end

  def data
    @this_month = params[:date] ? Date.parse(params[:date]) : Date.today.beginning_of_month
    date = params[:date] ? Date.parse(params[:date]) : Date.today
    @dates = get_days_from_month(date).reverse
  end

  def update_entries
    if admin_params[:entry_ids]
      @entries = Entry.find(admin_params[:entry_ids])
      unpublished_ids = admin_params[:unpublished_ids] ? admin_params[:unpublished_ids] : []
      @entries.each do |e|
        if unpublished_ids.include?(e.id.to_s)
          if e.published == true
            e.published = false
            e.save
          end
        else
          if e.published == false
            e.published = true
            e.save
          end
        end
      end
      flash[:notice] = "新聞更新完畢！"
    end
    redirect_to admin_entries_path
  end

  def update_interpellations
    if admin_params[:interpellation_ids]
      @interpellations = Interpellation.find(admin_params[:interpellation_ids])
      unpublished_ids = admin_params[:unpublished_ids] ? admin_params[:unpublished_ids] : []
      @interpellations.each do |q|
        if unpublished_ids.include?(q.id.to_s)
          if q.published == true
            q.published = false
            q.save
          end
        else
          if q.published == false
            q.published = true
            q.save
          end
        end
      end
      flash[:notice] = "質詢更新完畢！"
    end
    redirect_to admin_interpellations_path
  end

  def update_videos
    if admin_params[:video_ids]
      @videos = Video.find(admin_params[:video_ids])
      unpublished_ids = admin_params[:unpublished_ids] ? admin_params[:unpublished_ids] : []
      @videos.each do |v|
        if unpublished_ids.include?(v.id.to_s)
          if v.published == true
            v.published = false
            v.save
          end
        else
          if v.published == false
            v.published = true
            v.save
          end
        end
      end
      flash[:notice] = "影片更新完畢！"
    end
    redirect_to admin_videos_path
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def admin_params
    params.permit({entry_ids: []}, {interpellation_ids: []},
      {video_ids: []}, {unpublished_ids: []}, :date)
  end

  def get_days_from_month(date)
    date_start = date.beginning_of_month
    date_end = date.end_of_month
    if date_end > Date.today
      date_end = Date.today
    end
    date_range = date_start..date_end
    month_days = date_range.map {|d| Date.new(d.year, d.month, d.day) }.uniq
    month_days.map {|d| d.to_datetime }
  end
end
