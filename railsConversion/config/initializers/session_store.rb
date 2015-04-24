# Be sure to restart your server when you modify this file.

# Rails.application.config.session_store :cookie_store, key: '_bit_and_stone_session'
Rails.application.config.session_store :cookie_store, {
  :key =>           '_bit_and_stone_session',
  :path =>          '/',
  :domain =>        nil,   # accepted domain, for example '.example.com'  
  :expire_after =>  nil,   # the session will be expired in X seconds unless active
  :secure =>        false, # if true, cookie is valid only on https
  # :httponly =>      true   # if true, javascript can't access the cookie
}