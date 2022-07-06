class AddReviewedCommentToAvalonItem < ActiveRecord::Migration[4.2]
  def change
    add_column :avalon_items, :reviewed_comment, :text
  end
end
