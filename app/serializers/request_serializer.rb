class RequestSerializer < ActiveModel::Serializer
  attributes :id, :url, :email, :created_at, :token, :varsymbol, :sms_guide_html
end
