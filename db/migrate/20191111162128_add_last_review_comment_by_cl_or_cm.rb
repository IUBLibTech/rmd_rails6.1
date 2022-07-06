class AddLastReviewCommentByClOrCm < ActiveRecord::Migration[4.2]
  def up
    add_column :avalon_items, :last_review_comment_by_cl, :boolean, null: true unless column_exists? :avalon_items, :last_review_comment_by_cl
    add_column :avalon_items, :last_review_comment_by_cm, :boolean, null: true unless column_exists? :avalon_items, :last_review_comment_by_cm
  end

  def down
    remove_column :avalon_items, :last_review_comment_by_cl, :boolean, null: true if column_exists? :avalon_items, :last_review_comment_by_cl
    remove_column :avalon_items, :last_review_comment_by_cm, :boolean, null: true if column_exists? :avalon_items, :last_review_comment_by_cm
  end
end
