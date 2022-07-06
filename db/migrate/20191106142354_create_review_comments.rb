class CreateReviewComments < ActiveRecord::Migration[4.2]
  def change
    create_table :review_comments do |t|
      t.integer :avalon_item_id
      t.string :creator, null: false
      t.boolean :copyright_librarian
      t.text :comment, null: false
      t.timestamps null: false
    end

    AvalonItem.all.each do |ai|
      ReviewComment.new(avalon_item_id: ai.id, creator: ai.review_requester, copyright_librarian: false, comment: ai.needs_review_comment).save! if ai.needs_review?
      ReviewComment.new(avalon_item_id: ai.id, creator: 'nazapant', copyright_librarian: true, comment: ai.reviewed_comment).save! if ai.reviewed?
    end

    remove_column :avalon_items, :needs_review_comment
    remove_column :avalon_items, :review_requester
    remove_column :avalon_items, :reviewed_comment
  end
end
