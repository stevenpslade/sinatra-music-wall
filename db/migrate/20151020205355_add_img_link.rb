class AddImgLink < ActiveRecord::Migration
  def change
    change_table :songs do |t|
      t.string :img_link
    end
  end
end
