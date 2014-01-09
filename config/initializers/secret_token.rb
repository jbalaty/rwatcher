# Be sure to restart your server when you modify this file.

# Your secret key is used for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid!

# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.
# You can use `rake secret` to generate a secure secret key.

# Make sure your secret_key_base is kept private
# if you're sharing your code publicly.
#Rwatcher::Application.config.secret_key_base = '38953befed042e06d0d197f3246a7e4baac1605949df4e9a00803422ea0db7f6a839eb84005de43c4a5e9cdc86c8a560b2719643209ea1522e7e7894697a3c76'

Rwatcher::Application.config.secret_key_base = if Rails.env.development? or Rails.env.test?
                                                 ('x' * 30) # meets minimum requirement of 30 chars long
                                               else
                                                 ENV['SECRET_TOKEN']
                                               end