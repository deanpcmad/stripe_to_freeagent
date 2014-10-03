class Import < ActiveRecord::Base

  belongs_to :user
  belongs_to :stripe_account
  belongs_to :freeagent_account

  before_validation :generate_token, unless: Proc.new { |model| model.persisted? }

  private

  def generate_token
    self.token = SecureRandom.uuid
  end

end