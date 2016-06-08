# == Schema Information
#
# Table name: purchases
#
#  id          :integer          not null, primary key
#  user_id     :integer
#  document_id :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class Purchase < ActiveRecord::Base
  belongs_to :user
  belongs_to :document

  ADMIN_PERCENTAGE = 0.2

  def calculate_days_of_purcharse
    (Time.now.to_date - self.updated_at.to_date).to_i
  end

  serialize :notification_params, Hash

  def completed?
    !!(self.status.present? and self.status.downcase == 'completed')
  end

  def paypal_url(return_path)
    values = {
        business: "#{Rails.application.secrets.business_account}",
        cmd: "_xclick",
        upload: 1,
        return: "#{Rails.application.secrets.app_host}#{return_path}",
        invoice: id,
        amount: 0.1, #TODO change this amount
        item_name: document.title,
        item_number: document.id,
        quantity: '1',
        notify_url: "#{Rails.application.secrets.app_host}/hook"
    }
    "#{Rails.application.secrets.paypal_host}/cgi-bin/webscr?" + values.to_query
  end

  def is_expired?
    self.calculate_days_of_purcharse >
      Document.find(self.document_id).life_time_category
  end
end
