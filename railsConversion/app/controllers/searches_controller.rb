class SearchesController < ApplicationController
  # before_action :set_search, only: [:show, :edit, :update, :destroy]
  # before_action :set_search_results, only: [:search]

  def set_search_results
     # @searchResults = Cachequery.find_by_sql("select * from domain_caches where name like '%dot%' limit 100;")
     # render json: CacheQuery.find_by_sql("select * from domain_caches where name like '%#{search_params}%';")
    # @searchResults = CacheQuery.find_by_sql(" select * from domain_caches where name like '%#{params[:userQuery]}%';")
  end

  def search
    @searchResults=[]
    # limit= params[:limit] || 100 
    histnum= params[:histnum] || 100
    resultsWithHistories= {}
    if params[:blackHabbitPrimarySearch] == nil then
      @searchResults = 'No Search Requested'
      return
    else
      @searchResults = NmcChainEntry.where("link->>'value' like ?","%#{params[:blackHabbitPrimarySearch]}%").limit(100)
    end
    # render json: @searchResults
    render json: @searchResults, :include => { :addresses => {:include => {:tags => {:only=>:title}}}}  #This just handles the sql magicaly - seriously.
    # @searchResults.each do |x| 

    #   # x.possible_addresses.each {|o| puts o.categories}
    # end
  


  end

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


    def set_search_results #returns 100 results with the first 10 results including their histories.

      limit= params[:limit] || 100 
      histnum= params[:histnum] || 10

      if params[:blackHabbitPrimarySearch] == nil then
        @searchResults = 'No Search Requested'
        return
      else
        # @searchResults = Cachequery.find_by_sql("select * from domain_caches where name like '%dot%' limit 100;")
        # d = DomainCache.find_by_sql("select * from domain_caches where name like '%#{params[:blackHabbitPrimarySearch]}%' limit 1000;")
        @searchResults[0..histnum].each do |h|
          all_histories={}
          h.histories.each do |o|
            all_histories[:address]=o[:address]
            all_histories[:domain_cache_id]=o[:domain_cache_id]
            all_histories[:transactionId]=o[:transactionId]
            @searchResults.push(all_histories)
          end
          puts @searchResults
        end 

      end
    end

    def search_params
      params.require(:blackHabbitPrimarySearch).permit(:histnum,:limit)
    end
end
 # select * from nmc_chain_links jsonb_to_recordset(x) where link->>'value' like '%"ip":%';  USES JSONB!!!