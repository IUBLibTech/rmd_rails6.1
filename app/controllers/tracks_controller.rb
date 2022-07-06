class TracksController < ApplicationController
  before_action :set_track

  def create
    ajax_create_track
  end
  def show
    @track = Track.find(params[:id])
    render partial: 'tracks/ajax_show', locals: {track: @track}
  end
  def update
    respond_to do |format|
      @track = Track.find(params[:id])
      if @track.update(track_params)
        format.html { render partial: 'tracks/ajax_show', locals: {track: @track} }
      else
        format.html { render :edit }
      end
    end
  end

  def ajax_new_track
    @performance = Performance.find(params[:performance_id])
    @track = Track.new(performance_id: @performance.id)
    render partial: 'tracks/ajax_new_track'
  end

  def ajax_edit_track
    @track = Track.find(params[:track_id])
    render partial: 'tracks/ajax_edit_track'
  end

  def ajax_update_track

  end

  def ajax_create_track
    track = Track.new(track_params)
    if track.save!
      render partial: 'tracks/ajax_show', locals: { track: track }
    else
      render text: "An unexpected error occurred trying to create the Track", status: 500
    end
  end

  def ajax_access_determination
    @track = Track.find(params[:id])
    access = params[:access]
    if AccessDeterminationHelper::ACCESS_DECISIONS.include? access
      @saved = @track.update(access_determination: access)
    end
    render text: "success"
  end

  # DELETE /performances/1
  # DELETE /performances/1.json
  def destroy
    begin
      if @track.destroy
        render text: "success", status: 200
      else
        render text: "An unexpected error occurred trying to delete the Track", status: 500
      end
    rescue
      render text: "An unexpected error occurred trying to delete the specified Performance", status: 500
    end
  end

  private
  def set_track
    if params[:performance_id]
      @performance = Performance.find(params[:performance_id])
    end
    if params[:id]
      @track = Track.find(params[:id])
    elsif params[:track_id]
      @track = Track.find(params[:track_id])
    end
  end
  def track_params
    params.require(:track).permit(
        :performance_id, :track_name, :recording_start_time, :recording_end_time, :in_copyright, :copyright_end_date_text, :access_determination
    )
  end
end
