class User < ActiveRecord::Base

  authenticates_with_sorcery!

  validates :password, length: { minimum: 3 }
  validates :password, confirmation: true
  validates :password_confirmation, presence: true

  validates :email, uniqueness: true

  before_validation :generate_token, unless: Proc.new { |model| model.persisted? }

  has_many :freeagent_accounts
  has_many :stripe_accounts
  has_many :imports

  private

  def generate_token
    self.token = SecureRandom.uuid
  end

end