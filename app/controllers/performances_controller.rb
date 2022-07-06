class PerformancesController < ApplicationController
  before_action :set_performance, only: [:show, :edit, :update, :destroy]

  # GET /performances
  # GET /performances.json
  def index
    @performances = Performance.all
  end

  # GET /performances/1
  # GET /performances/1.json
  def show
  end

  # GET /performances/new
  def new
    @performance = Performance.new
  end

  # GET /performances/1/edit
  def edit
  end

  # POST /performances
  # POST /performances.json
  def create
    @performance = Performance.new(performance_params)
    Performance.transaction do
      respond_to do |format|
        if @performance.save
          @recording_performance = RecordingPerformance.new(recording_id: params[:recording_id], performance_id: @performance.id)
          if  @recording_performance.save
            format.html { render partial: 'performances/ajax_show', locals: {performance: @performance}, notice: 'Performance was successfully created.' }
          else
            format.html { render :new }
          end
        else
          format.html { render :new }
        end
      end
    end
  end

  # PATCH/PUT /performances/1
  # PATCH/PUT /performances/1.json
  def update
    respond_to do |format|
      if @performance.update(performance_params)
        format.html { render partial: 'performances/ajax_show', locals: {performance: @performance} }
      else
        format.html { render :edit }
      end
    end
  end

  # DELETE /performances/1
  # DELETE /performances/1.json
  def destroy
    begin
      if @performance.tracks.size == 0
        @performance.destroy
        render text: "success", status: 200
      else
        render text: "You cannot delete a Performance with Tracks", status: 409
      end
    rescue
      render text: "An unexpected error occurred trying to delete the specified Performance", status: 500
    end
  end

  def ajax_new_performance
    @recording = Recording.find(params[:recording_id])
    @performance = Performance.new
    render partial: 'performances/ajax_new'
  end

  def ajax_edit_performance
    @performance = Performance.find(params[:id])
    render partial: "performances/ajax_edit"
  end

  def ajax_show_performance
    @performance = Performance.find(params[:id])
    render partial: 'performances/ajax_show', locals: {performance: @performance}
  end

  def ajax_access_determination
    @performance = Performance.find(params[:id])
    access = params[:access]
    if AccessDeterminationHelper::ACCESS_DECISIONS.include? access
      @saved = @performance.update(access_determination: access)
    end
    render text: "success"
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_performance
      @performance = Performance.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def performance_params
      params.require(:performance).permit(:location, :performance_date_string, :performance_date, :title, :notes, :access_determination)
    end
end
