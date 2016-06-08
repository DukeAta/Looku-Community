# == Schema Information
#
# Table name: documents
#
#  id            :integer          not null, primary key
#  user_id       :integer
#  file          :string
#  title         :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  document_type :string
#  score         :integer
#  university    :string
#  institution   :string
#  country       :string
#  level         :string
#  year          :integer
#  is_verified   :boolean          default(FALSE)
#  price         :integer
#  word_count    :integer
#  category      :string
#  preview_page      :integer

class Document < ActiveRecord::Base
  ratyrate_rateable 'document'
  mount_uploader :file, FileUploader

  paginates_per 6

  belongs_to :user
  has_many :purchases, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :votes, dependent: :destroy

  validates :user, presence: true
  validates :file, presence: true
  validates :category, inclusion: ['essay', 'dissertation', 'assignment', 'project']

  enum doc_category: ["essay", "dissertation", 'assignment', 'project']
  enum resource_type: [:turnitin, :normal]
#  CATEGORY_ASSAY = 7
#  CATEGORY_DISSERTATION = 10
  CATEGORY_ASSAY = 1
  CATEGORY_DISSERTATION = 1
  SUGGESTED_ESSAY_PRICE = 20
  SUGGESTED_DISSERTATION_PRICE = 10

  def self.search(search)
    if search
      self.where("title like ?", "%#{search}%")
    else
      self.all
    end
  end

  def life_time_category
    if self.category == "essay"
      CATEGORY_ASSAY
    elsif self.category == "dissertation"
      CATEGORY_DISSERTATION
    end
  end

  def verified!
    self.is_verified = true
    self.save
  end

end
