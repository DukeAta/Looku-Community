# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string
#  last_sign_in_ip        :string
#  confirmation_token     :string
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#  unconfirmed_email      :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  first_name             :string
#  last_name              :string
#  middle_name            :string
#  user_category          :integer
#  employer               :string
#  education_institution  :string
#  country                :string
#  is_verified            :boolean          default(FALSE)
#  image                  :string
#  coin                   :integer
#

class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  User.connection
  ratyrate_rater
  mount_uploader :image, AvatarUploader

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable, :omniauthable
  
  has_many :documents, dependent: :destroy
  has_many :purchases, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :votes, dependent: :destroy

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, presence: true

  validates :user_category, presence: true # 1: strudent, 2: non student

  def self.find_for_oauth(auth, signed_in_resource = nil)
    identity = Identity.find_for_oauth auth
    user = signed_in_resource ? signed_in_resource : identity.user
    if user.nil?
      email = auth.info.email
      user = email.nil? ? User.where(provider: auth.provider, uid: auth.uid).first : User.find_by(email: email)
      # Create the user if it's a new registration
      if user.nil?
        user = User.new(
          provider: auth.provider,
          uid: auth.uid,
          first_name: auth.extra.raw_info.name.split(" ").first,
          last_name: auth.extra.raw_info.name.split(" ").last,
          email: email ? email : "#{auth.provider+auth.uid}@docshare.com",
          password: Devise.friendly_token[0, 20],
          remote_image_url: auth.info.image.gsub('http:','https:')+"?fields=picture&type=large"
        )
        user.skip_confirmation!
        user.save!(validate: false)
        UserMailer.after_email_confirmation(user).deliver_now if email.present?
      end
    end
    user
  end

  def defaul_first_name
    if self.first_name.present?
      return self.first_name
    else
      return self.email.split("@").first.titlecase
    end
  end

  def verify?
    return self.is_verified
  end

  def after_confirmation
    self.update_attribute(:is_verified, true)
    UserMailer.after_email_confirmation(User.find_by_id(self.id)).deliver_now
  end

  def name
    return self.first_name + ' ' + self.last_name
  end

  def update_with_password(params={})
    if params[:password].blank?
      params.delete(:password)
      params.delete(:password_confirmation) if params[:password_confirmation].blank?
    end
    update_attributes(params)
  end
end
