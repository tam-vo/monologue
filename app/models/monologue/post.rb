class Monologue::Post < ActiveRecord::Base
  has_many :taggings
  has_many :tags, -> { order "id ASC" }, through: :taggings, dependent: :destroy
  before_validation :generate_assign_url
  before_validation :assign_data
  belongs_to :user
  belongs_to :category

  scope :default,  -> {order("published_at DESC, monologue_posts.created_at DESC, monologue_posts.updated_at DESC") }
  scope :published, -> { default.where(published: true).where("published_at <= ?", DateTime.now) }
  scope :pinned, -> { where(pinned: true) }
  scope :blog, -> { where(category_id: nil) }

  scope :order_incr_position, -> { order("position ASC") }

  default_scope{includes(:tags)}

  validates :user_id, presence: true
  validates :title, :content, :url, :published_at, presence: true
  validates :url, uniqueness: true
  validate :url_do_not_start_with_slash

  delegate :name, to: :category, prefix: true, allow_nil: true

  def tag_list= tags_attr
    self.tag!(tags_attr.split(","))
  end

  def tag_list
    self.tags.map { |tag| tag.name }.join(", ") if self.tags
  end

  def tag!(tags_attr)
    self.tags = tags_attr.map(&:strip).reject(&:blank?).map do |tag|
      Monologue::Tag.where(name: tag).first_or_create
    end
  end

  def full_url
    "#{Monologue::Engine.routes.url_helpers.root_path}#{self.url}"
  end

  def published_in_future?
    self.published && self.published_at > DateTime.now
  end

  def self.page p
    per_page = Monologue::Config.posts_per_page || 10
    set_total_pages(per_page)
    p = (p.nil? ? 0 : p.to_i - 1)
    offset =  p * per_page
    self.limit(per_page).offset(offset)
  end

  def self.total_pages
    @number_of_pages
  end

  def self.set_total_pages per_page
    @number_of_pages = self.count / per_page + (self.count % per_page == 0 ? 0 : 1)
  end

  def self.generate_uniq_url(title)
    slug = title.to_url
    valid = true
    base_slug = slug
    if Monologue::Post.find_by_url(slug)
      index = 2
      slug = "#{base_slug}-#{index}"
      while Monologue::Post.find_by_url(slug)
        index += 1
        slug = "#{base_slug}-#{index}"
      end
    end
    slug
  end

  def generate_assign_url
    return unless self.url.blank?
    return if self.title.blank?

    self.url = Post.generate_uniq_url(self.title)
  end

  private
  def url_do_not_start_with_slash
    errors.add(:url, I18n.t("activerecord.errors.models.monologue/post.attributes.url.start_with_slash")) if self.url.start_with?("/")
  end

  def assign_data
    self.published_at = Time.now if self.published_at.blank?
    self.published = false if self.published.nil?
  end
end
