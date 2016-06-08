# == Schema Information
#
# Table name: charges
#
#  id          :integer          not null, primary key
#  user_id     :integer
#  document_id :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

# Charge model, generated when user download - buy a document
class Charge < ActiveRecord::Base
  belongs_to :user
  belongs_to :document

end
