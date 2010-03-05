# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_sillarai_session',
  :secret      => '12054bb4474ce25a39aaf85d8773f9da6d12fb45aeaed5a6739eb4bfc6d5ae3eafd6805bc4756a3d471ddbc6c66696ec7aa2041ba0cd514703ecd9914f1434b9'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
