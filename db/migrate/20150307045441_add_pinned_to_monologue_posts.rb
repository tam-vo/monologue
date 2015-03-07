class AddPinnedToMonologuePosts < ActiveRecord::Migration
  def change
    add_column :monologue_posts, :pinned, :boolean, default: false
  end
end
