class StripeAccount < ActiveRecord::Base
  
  belongs_to :user

  def self.from_omniauth(user, auth)
    where(uid: auth.uid).first_or_initialize.tap do |acc|
      acc.user = user
      acc.uid = auth.uid
      acc.token = auth.credentials.token
      acc.publishable_key = auth.extra.raw_info.stripe_publishable_key
      acc.stripe_user_id = auth.extra.raw_info.stripe_user_id
      acc.save!
    end
  end

end