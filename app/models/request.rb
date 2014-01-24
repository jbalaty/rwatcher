class Request < ActiveRecord::Base
  has_and_belongs_to_many :search_infos
  before_save :default_values

  validates :url, :email, presence: true
  validates :url, :format => URI::regexp(%w(http https))
  validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i

  # non persistent attributes
  attr_accessor :sms_guide_html, :tarrif_parsed

  def default_values
    self.token ||= SecureRandom.urlsafe_base64
    if self.id
      self.varsymbol ||= self.generate_varsymbol self.id # but dont forget to not use 'Z' in further number to alphabet code translation
    end
  end

  def generate_varsymbol(id)
    "Z#{id}"
  end

  def get_tarrif(numads)
    #other_request_by_email = self.find_all_by_email(self.email)
    if numads < 100
      return %w{T0 FREE}
    end
    if numads < 500
      return %w{T0 50}
    elsif numads < 5000
      return %w{T0 149}
    else
      return %w{T0 INDIVIDUAL}
    end
  end

  def get_sms_phone_number(amount)
    case amount
      when '50'
        return '9033350'
      when '149'
        return '90333'
      else
        raise Exception 'Wrong amount, don\'t have sms number for it'
    end
  end

  def addFailedAttempt
    self.numFailedAttempts += 1;
    if !self.firstFailedAttempt
      self.firstFailedAttempt = DateTime.now
    end
  end
end
