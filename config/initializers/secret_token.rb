unless File.exists?("config/secret_token.yml")
  File.open("config/secret_token.yml", "w") do |f|
    f.write SecureRandom.hex(128).to_yaml
  end
end

StripeToFreeagent::Application.config.secret_key_base = YAML.load(File.read("config/secret_token.yml"))