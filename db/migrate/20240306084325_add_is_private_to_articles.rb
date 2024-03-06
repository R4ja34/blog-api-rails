class AddIsPrivateToArticles < ActiveRecord::Migration[7.1]
  def change
    add_column :articles, :is_private, :boolean
  end
end
