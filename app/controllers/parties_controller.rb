class PartysController < ApplicationController
  before_action :set_party, except: [:index, :new]

  # GET /parties
  def index
    @parties = Party.all.page params[:page]
  end

  # GET /parties/1
  def show
  end

  # GET /parties/new
  def new
    @party = Party.new
  end

  # GET /parties/1/edit
  def edit
  end

  # POST /parties
  def create
    @party = Party.new(party_params)
    if @party.save
        redirect_to @party, notice: '關鍵字建立成功'
    else
      render :new
    end
  end

  # PATCH/PUT /parties/1
  def update
    if @party.update(party_params)
      redirect_to @party, notice: '關鍵字更新成功'
    else
      render :edit
    end
  end

  # DELETE /parties/1
  def destroy
    @party.destroy
    redirect_to parties_url, notice: '關鍵字已刪除'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_party
      @party = params[:id] ? Party.find(params[:id]) : Party.new(party_params)
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def party_params
      params.require(:party).permit(:name)
    end
end
