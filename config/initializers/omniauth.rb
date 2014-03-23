OmniAuth.config.logger = Rails.logger

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :freeagent, ENV["FREEAGENT_ID"], ENV["FREEAGENT_SECRET"]
end