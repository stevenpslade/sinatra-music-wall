class AddUpvote < ActiveRecord::Migration
  def change
    create_table :likes do |t|
      t.references :user
      t.references :song
      t.string :like_type
      t.timestamps
    end
  end
end
