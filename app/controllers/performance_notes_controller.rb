class PerformanceNotesController < ApplicationController

  def new
    @performance = Performance.find(params[:performance_id])
    @performance_note = PerformanceNote.new(performance_id: @performance.id, creator: User.current_username)
    render partial: 'performance_notes/form'
  end

  def create
    @performance = Performance.find(params[:performance_note][:performance_id])
    @performance_note = PerformanceNote.new(performance_notes_params)
    respond_to do |format|
      if @performance_note.save
        format.js {}
      end
    end
  end

  private
  def performance_notes_params
    params.require(:performance_note).permit(:performance_id, :text, :creator)
  end
end
