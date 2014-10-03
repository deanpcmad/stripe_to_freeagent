class FreeagentAccount < ActiveRecord::Base

  belongs_to :user

  def self.from_omniauth(user, auth)
    where(uid: auth.uid).first_or_initialize.tap do |acc|
    	acc.user = user
      acc.uid = auth.uid
      acc.email = auth.info.email
      acc.token = auth.credentials.token
      acc.refresh_token = auth.credentials.refresh_token
      acc.expires_at = Time.at(auth.credentials.expires_at)
      acc.save!
    end
  end

  def refresh_token
    response    = RestClient.post "https://api.freeagent.com/v2/token_endpoint", :grant_type => 'refresh_token', :refresh_token => self.refresh_token, :client_id => ENV["FREEAGENT_ID"], :client_secret => ENV["FREEAGENT_SECRET"] 
    refreshhash = JSON.parse(response.body)

    token_will_change!
    expires_at_will_change!

    self.token     = refreshhash['access_token']
    self.expires_at = DateTime.now + refreshhash["expires_in"].to_i.seconds

    self.save
  end

  def token_expired?
    expiry = Time.at(self.expires_at) 
    return true if expiry < Time.now # expired token, so we should quickly return
    token_expires_at = expiry
    save if changed?
    false # token not expired. :D
  end

end