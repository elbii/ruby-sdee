require 'sdee'

# create new SDEE connection
poller = SDEE::Poller.new(
  host: 'localhost',
  user: 'user',
  password: 'pass')

# login and set subscriptionId, sessionId
poller.login

# print events every 1 second in JSON format
poller.poll_events 1
