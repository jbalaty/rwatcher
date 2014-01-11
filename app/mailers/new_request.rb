# encoding:UTF-8
class NewRequest < ActionMailer::Base
  default from: 'info@pcin.cz'
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.change_notifier.SearchInfoChangeSummary.subject
  #
  def SearchInfoChangeSummary(request, notifications)
    @request = request
    @notifications = notifications.sort_by! do |n|
      [n.search_info.id, n.created_at]
    end

    mail to: request.email, subject: 'Nové inzeráty na SReality.cz'
  end

end
