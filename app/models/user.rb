class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable

  before_validation :generate_token, unless: Proc.new { |model| model.persisted? }

  has_many :freeagent_accounts
  has_many :stripe_accounts
  has_many :imports

  private

  def generate_token
  	self.token = SecureRandom.uuid
  end

end