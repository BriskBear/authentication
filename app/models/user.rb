class User < ApplicationRecord
  CONFIRMATION_TOKEN_EXPIRATION = 10.minutes
  MAILER_FROM_EMAIL = "no-reply@example.com" 

  has_secure_password

  before_save :downcase_email

  validates :email, format: {with: URI::MailTo::EMAIL_REGEXP}, presence: true, uniqueness: true
  validates :username, presence: true, uniqueness: true

  def confirm!
    update_columns(confirmed_at: Time.current.to_i)
  end

  def confirmed?
    confirmed_at.present?
  end

  def generate_confirmation_token
    signed_id expires_in: CONFIRMATION_TOKEN_EXPIRATION, purpose: :confirm_email
  end

  def unconfirmed?
    !confirmed?
  end

  private

  def downcase_email
    self.email = email.downcase
  end

  def send_confirmation_email!
    confirmation_token = generate_confirmation_token
    UserMailer.confirmation(self, confirmation_token).deliver_now
  end
end
