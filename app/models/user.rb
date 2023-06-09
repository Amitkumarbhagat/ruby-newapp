# app/models/user.rb
class User < ApplicationRecord
    CONFIRMATION_TOKEN_EXPIRATION = 10.minutes
  
    has_secure_password
  
    before_save :downcase_email
  
    validates :email, format: {with: URI::MailTo::EMAIL_REGEXP}, presence: true, uniqueness: true
  
    def confirm!
      update_columns(confirmed_at: Time.current)
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

    MAILER_FROM_EMAIL = "no-reply@example.com"
  
    private
  
    def downcase_email
      self.email = email.downcase
    end

    def send_confirmation_email!
      confirmation_token = generate_confirmation_token
      UserMailer.confirmation(self, confirmation_token).deliver_now
    end

    PASSWORD_RESET_TOKEN_EXPIRATION = 10.minutes

    def generate_password_reset_token
      signed_id expires_in: PASSWORD_RESET_TOKEN_EXPIRATION, purpose: :reset_password
    end

    def send_password_reset_email!
      password_reset_token = generate_password_reset_token
      UserMailer.password_reset(self, password_reset_token).deliver_now
    end

    attr_accessor :current_password
   
    before_save :downcase_unconfirmed_email
  
    validates :unconfirmed_email, format: {with: URI::MailTo::EMAIL_REGEXP, allow_blank: true}
  
    def confirm!
      if unconfirmed_or_reconfirming?
        if unconfirmed_email.present?
          return false unless update(email: unconfirmed_email, unconfirmed_email: nil)
        end
        update_columns(confirmed_at: Time.current)
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
    
    def reconfirming?
      unconfirmed_email.present?
    end
  
    def unconfirmed_or_reconfirming?
      unconfirmed? || reconfirming?
    end
  
    private
  
    def downcase_unconfirmed_email
      return if unconfirmed_email.nil?
      self.unconfirmed_email = unconfirmed_email.downcase
    end

  end
  
  