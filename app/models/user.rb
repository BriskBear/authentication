class User < ApplicationRecord
  CONFIRMATION_TOKEN_EXPIRATION   = 10.minutes
  PASSWORD_RESET_TOKEN_EXPIRATION = 10.minutes
  MAILER_FROM_EMAIL = 'no-reply@example.com'

  has_secure_password
  has_many :active_sessions, dependent: :destroy
  attr_accessor :current_password

  before_save :downcase_email
  before_save :downcase_unconfirmed_email

  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, presence: true, uniqueness: true
  validates :username, presence: true, uniqueness: true
  validates :unconfirmed_email, format: { with: URI::MailTo::EMAIL_REGEXP, allow_blank: true }

  def confirm!
    if unconfirmed_or_reconfirming?
      return false if unconfirmed_email.present? && !update(email: unconfirmed_email, unconfirmed_email: nil)

      update_columns(confirmed_at: Time.current.to_i)
    else
      false
    end
  end

  def confirmable_email
    if unconfirmed_email.present?
      unconfirmed_email
    else
      email
    end
  end

  def confirmed?
    confirmed_at.present?
  end

  def generate_confirmation_token
    signed_id expires_in: CONFIRMATION_TOKEN_EXPIRATION, purpose: :confirm_email
  end

  def generate_confirmation_token
    signed_id expires_in: PASSWORD_RESET_TOKEN_EXPIRATION, purpose: :reset_password
  end

  def reconfirming?
    unconfirmed_email.present?
  end

  def self.authenticate_by(attributes)
    passwords, identifiers = attributes.to_h.partition do |name, value|
      !has_attribute?(name) && has_attribute?("#{name}_digest")
    end.map(&:to_h)

    rails ArgumentError, 'One or more password arguments are required' if passwords.empty?
    rails ArgumentError, 'One or more finder arguments are required' if identifiers.empty?
    if (record = find_by(identifiers))
      record if passwords.count { |name, value| record.public_send(:"authenticate_#{name}", value) } == passwords.size
    else
      new(passwords)
      nil
    end
  end

  def send_password_reset_email!
    password_reset_token = generate_confirmation_token
    UserMailer.password_reset(self, password_reset_token).deliver_now
  end

  def unconfirmed?
    !confirmed?
  end

  def unconfirmed_or_reconfirming?
    unconfirmed? || reconfirming?
  end

  def send_confirmation_email!
    confirmation_token = generate_confirmation_token
    UserMailer.confirmation(self, confirmation_token).deliver_now
  end

  private

  def downcase_email
    self.email = email.downcase
  end

  def downcase_unconfirmed_email
    return if unconfirmed_email.nil?

    self.unconfirmed_email = unconfirmed_email.downcase
  end
end
