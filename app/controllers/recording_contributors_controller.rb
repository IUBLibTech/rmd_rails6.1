class RecordingContributorsController < ApplicationController
  before_action :set_recording_contributor, only: [:show, :edit, :update, :destroy]

  # GET /recording_contributors
  # GET /recording_contributors.json
  def index
    @recording_contributors = RecordingContributor.all
  end

  # GET /recording_contributors/1
  # GET /recording_contributors/1.json
  def show
  end

  # GET /recording_contributors/new
  def new
    @recording_contributor = RecordingContributor.new
  end

  # GET /recording_contributors/1/edit
  def edit
  end

  # POST /recording_contributors
  # POST /recording_contributors.json
  def create
    @recording_contributor = RecordingContributor.new(recording_contributor_params)

    respond_to do |format|
      if @recording_contributor.save
        format.html { redirect_to @recording_contributor, notice: 'Recording contributor was successfully created.' }
        format.json { render :show, status: :created, location: @recording_contributor }
      else
        format.html { render :new }
        format.json { render json: @recording_contributor.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /recording_contributors/1
  # PATCH/PUT /recording_contributors/1.json
  def update
    respond_to do |format|
      if @recording_contributor.update(recording_contributor_params)
        format.html { redirect_to @recording_contributor, notice: 'Recording contributor was successfully updated.' }
        format.json { render :show, status: :ok, location: @recording_contributor }
      else
        format.html { render :edit }
        format.json { render json: @recording_contributor.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /recording_contributors/1
  # DELETE /recording_contributors/1.json
  def destroy
    @recording_contributor.destroy
    respond_to do |format|
      format.html { redirect_to recording_contributors_url, notice: 'Recording contributor was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_recording_contributor
      @recording_contributor = RecordingContributor.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def recording_contributor_params
      params.fetch(:recording_contributor, {})
    end
end
