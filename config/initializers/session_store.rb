# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_gg2_session',
  :secret      => '639ab87cf284c09f23bbde539cb16bd76775948c7aeca69a034b79109200189a3172f6a01ac5bb0f8fae82ce03c8aef252259825ead9861fd4358ec9c0efbe43'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
