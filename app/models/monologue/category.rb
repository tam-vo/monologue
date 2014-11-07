class Monologue::Category < ActiveRecord::Base
  has_many :posts
  belongs_to :main_post, class_name: "Post", foreign_key: :main_post_id
  before_validation :generate_slug

  validates :name, :slug, presence: true

  private
  def generate_slug
    return unless self.slug.blank?
    return if self.name.blank?
    slug = self.name.to_url
    valid = true
    base_slug = slug
    if Monologue::Category.find_by_slug(slug)
      index = 2
      slug = "#{base_slug}-#{index}"
      while Monologue::Post.find_by_url(slug)
        index += 1
        slug = "#{base_slug}-#{index}"
      end
    end
    self.slug = slug
  end
end
