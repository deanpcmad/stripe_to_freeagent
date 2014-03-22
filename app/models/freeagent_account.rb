class FreeagentAccount < ActiveRecord::Base

  belongs_to :user

  def self.from_omniauth(user, auth)
    where(auth.uid).first_or_initialize.tap do |acc|
    	acc.user = user
      acc.uid = auth.uid
      acc.email = auth.info.email
      acc.token = auth.credentials.token
      acc.refresh_token = auth.credentials.refresh_token
      acc.expires_at = Time.at(auth.credentials.expires_at)
      acc.save!
    end
  end

end