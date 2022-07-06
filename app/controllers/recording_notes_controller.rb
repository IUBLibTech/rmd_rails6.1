class RecordingNotesController < ApplicationController

  def new
    @recording = Recording.find(params[:recording_id])
    @recording_note = RecordingNote.new(recording_id: @recording.id, creator: User.current_username)
    render partial: 'recording_notes/form'
  end

  def create
    @recording = Recording.find(params[:recording_note][:recording_id])
    @avalon_item = @recording.avalon_item
    @recording_note = RecordingNote.new(recording_notes_params)
    respond_to do |format|
      if @recording_note.save
        format.js {}
      end
    end
  end

  private
  def recording_notes_params
    params.require(:recording_note).permit(:recording_id, :creator, :text)
  end

end
