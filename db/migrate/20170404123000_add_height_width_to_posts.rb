class AddHeightWidthToPosts < ActiveRecord::Migration[5.0]
  def change
    add_column :post_attachments, :width,  :float
    add_column :post_attachments, :height, :float
  end
end
