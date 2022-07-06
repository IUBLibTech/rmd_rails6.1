class AddNeedsReviewToRecording < ActiveRecord::Migration[4.2]
  def change
    add_column :recordings, :needs_review, :boolean, default: false
  end
end
