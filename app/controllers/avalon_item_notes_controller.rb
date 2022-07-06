class AvalonItemNotesController < ApplicationController

  def new
    @avalon_item = AvalonItem.find(params[:avalon_item_id])
    @avalon_item_note = AvalonItemNote.new(avalon_item_id: @avalon_item.id)
    render partial: 'avalon_item_notes/form'
  end

  def create
    @avalon_item = AvalonItem.find(params[:avalon_item_note][:avalon_item_id])
    @avalon_item_note = AvalonItemNote.new(avalon_item_notes_params)
    respond_to do |format|
      if @avalon_item_note.save
        format.js {}
      end
    end
  end

  private
  def avalon_item_notes_params
    params.require(:avalon_item_note).permit(:avalon_item_id, :text, :creator)
  end

end
