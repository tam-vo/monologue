class CreateMonologueCategories < ActiveRecord::Migration
  def change
    create_table :monologue_categories do |t|
      t.string :name
      t.string :slug, unique: true
      t.integer :main_post_id
    end

    add_column :monologue_posts, :category_id, :integer

    add_index :monologue_categories, :slug
    add_index :monologue_categories, :main_post_id
    add_index :monologue_posts, :category_id
  end
end
