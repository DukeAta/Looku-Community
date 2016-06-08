class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :document

  validates :user, presence: true
  validates :document, presence: true
  validates :content, presence: true
end
