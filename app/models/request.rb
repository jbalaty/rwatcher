class Request < ActiveRecord::Base
  has_and_belongs_to_many :search_infos
  before_save :default_values

  validates :url, :email, presence: true
  validates :url, :format => URI::regexp(%w(http https))
  validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i

  def default_values
    self.token ||= SecureRandom.urlsafe_base64
  end

  def addFailedAttempt
    self.numFailedAttempts += 1;
    if !self.firstFailedAttempt
      self.firstFailedAttempt = DateTime.now
    end
  end
end
