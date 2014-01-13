# encoding:UTF-8
class RequestNotifier < ActionMailer::Base
  default from: 'info@sledovani-realit.cz'
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.change_notifier.SearchInfoChangeSummary.subject
  #
  def NewRequestInfo(request)
    @request = request
    @deleteUrl = get_delete_url(@request.token)
    mail to: request.email, subject: 'Nové sledování realit'
  end

  def SearchInfoChangeSummary(request, notifications)
    @request = request
    @notifications = notifications.sort_by! do |n|
      [n.search_info.id, n.created_at]
    end
    @deleteUrl = get_delete_url(@request.token)
    mail to: request.email, subject: 'Nové inzeráty na SReality.cz'
  end

  private
  def get_delete_url(token)
    url_for(controller: "assets", action: "index", anchor: "/request/"+token+"/delete",
            only_path: false)
  end
end
