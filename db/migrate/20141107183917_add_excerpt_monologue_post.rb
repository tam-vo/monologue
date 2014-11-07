class AddExcerptMonologuePost < ActiveRecord::Migration
  def change
    add_column :monologue_posts, :excerpt, :string, limit: 1100
  end
end
