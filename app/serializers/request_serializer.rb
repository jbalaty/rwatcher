class RequestSerializer < ActiveModel::Serializer
  attributes :id, :url, :email, :created_at, :token
end
