class FeedsController < ApplicationController
  before_action :set_feed, only: [:show, :edit, :update, :destroy]

  # GET /feeds
  # GET /feeds.json
  def index
    @entries = Entry.all.order('created_at desc')

    if (( @entries.first.created_at - Time.now ) / 1.hour).round > 1 then

      Feed.all.each do |feed|
        content = Feedjira::Feed.fetch_and_parse feed.url
        content.entries.each do |entry|
          Thread.new do
            local_entry = feed.entries.where(title: entry.title).first_or_initialize

            if local_entry.content.nil?
              response = HTTParty.get("http://api.smmry.com/?&SM_API_KEY=33988A28D7&SM_LENGTH=4&SM_WITH_BREAK&SM_URL=" + entry.url)
              entry.content = response["sm_api_content"]
              local_entry.update_attributes(author: entry.author, url: entry.url, published: entry.published, summary: entry.summary, content: entry.content)
              local_entry.save
            end
            ActiveRecord::Base.connection.close
          end
        end
      end
    end
  end

  # GET /feeds/1
  # GET /feeds/1.json
  def show
  end

  # GET /feeds/new
  def new
    @feed = Feed.new
  end

  # GET /feeds/1/edit
  def edit
  end

  # POST /feeds
  # POST /feeds.json
  def create
    @feed = Feed.new(feed_params)

    respond_to do |format|
      if @feed.save
        format.html { redirect_to @feed, notice: 'Feed was successfully created.' }
        format.json { render :show, status: :created, location: @feed }
      else
        format.html { render :new }
        format.json { render json: @feed.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /feeds/1
  # PATCH/PUT /feeds/1.json
  def update
    respond_to do |format|
      if @feed.update(feed_params)
        format.html { redirect_to @feed, notice: 'Feed was successfully updated.' }
        format.json { render :show, status: :ok, location: @feed }
      else
        format.html { render :edit }
        format.json { render json: @feed.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /feeds/1
  # DELETE /feeds/1.json
  def destroy
    @feed.destroy
    respond_to do |format|
      format.html { redirect_to feeds_url, notice: 'Feed was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_feed
      @feed = Feed.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def feed_params
      params.require(:feed).permit(:name, :url, :description)
    end
end
