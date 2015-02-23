class SearchesController < ApplicationController
  # before_action :set_search, only: [:show, :edit, :update, :destroy]
  before_action :set_search, only: [:search]

  def set_search_results
     @searchResults = Cachequery.find_by_sql("select * from domain_caches where name like '%dot%' limit 100;")
     # render json: CacheQuery.find_by_sql("select * from domain_caches where name like '%#{search_params}%';")
    # @searchResults = CacheQuery.find_by_sql(" select * from domain_caches where name like '%#{params[:userQuery]}%';")
  end

  def search
    # @searchResults = Cachequery.standardSearch
    # @searchResults = Cachequery.find_by_sql("select * from domain_caches where name like '%weed%';")
    render json: @searchResults
  end


  # GET /searches/new
  def index
  end
  def new
    # @search = Search.new
  end

  # GET /searches/1/edit
  def edit
  end

  # POST /searches
  # POST /searches.json
  def create
    @search = Search.new(search_params)

    respond_to do |format|
      if @search.save
        format.html { redirect_to @search, notice: 'Search was successfully created.' }
        format.json { render :show, status: :created, location: @search }
      else
        format.html { render :new }
        format.json { render json: @search.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /searches/1
  # PATCH/PUT /searches/1.json
  def update
    respond_to do |format|
      if @search.update(search_params)
        format.html { redirect_to @search, notice: 'Search was successfully updated.' }
        format.json { render :show, status: :ok, location: @search }
      else
        format.html { render :edit }
        format.json { render json: @search.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /searches/1
  # DELETE /searches/1.json
  def destroy
    @search.destroy
    respond_to do |format|
      format.html { redirect_to searches_url, notice: 'Search was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_search
      if params[:blackHabbitPrimarySearch] == '' then
        @searchResults = ''
        return
      else
        @searchResults = Cachequery.find_by_sql("select * from domain_caches where name like '%#{params[:blackHabbitPrimarySearch]}%' limit 100;")
      # @search = Search.find(params[:blackHabbitPrimarySearch])
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    # def search_params
    #   params.require(:userQuery)
    #   # params.require(:search).permit(:userQuery)
    # end
end
