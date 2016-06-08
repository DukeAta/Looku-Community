class Vote < ActiveRecord::Base
  belongs_to :user
  belongs_to :document
  validates_uniqueness_of :user, scope: :document
end
