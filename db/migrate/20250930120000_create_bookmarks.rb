class CreateBookmarks < ActiveRecord::Migration[7.1]
  def change
    create_table :bookmarks do |t|
      t.references :user, null: false, foreign_key: true
      t.references :post, null: false, foreign_key: true

      t.timestamps
    end

    add_index :bookmarks, [:user_id, :post_id], unique: true

    add_column :posts, :bookmarks_count, :integer, default: 0, null: false
    add_index :posts, :bookmarks_count
  end
end
