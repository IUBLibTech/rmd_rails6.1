class AddReviewStateToAvalonItems < ActiveRecord::Migration[4.2]
  def change
    add_column :avalon_items, :review_state, :integer, default: AvalonItem::REVIEW_STATE_DEFAULT, null: false

    remove_column :avalon_items, :last_review_comment_by_cl, :boolean
    remove_column :avalon_items, :last_review_comment_by_cm, :boolean
  end
end
