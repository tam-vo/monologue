class AddExcerptMonologuePost < ActiveRecord::Migration
  def change
    add_column :monologue_posts, :excerpt, :string, limit: 1100
    add_column :monologue_posts, :position, :integer, default: 1
  end
end
