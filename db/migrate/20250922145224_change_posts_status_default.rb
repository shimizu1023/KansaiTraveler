class ChangePostsStatusDefault < ActiveRecord::Migration[7.1]
  def change
    change_column_default :posts, :status, from: nil, to: 0
    change_column_null :posts, :status, false, 0
  end
end
