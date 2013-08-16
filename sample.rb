require './sdee'

# create new SDEE connection
sdee = SDEE.new(host: 'localhost', user: 'user', pass: 'pass')

# login and set subscriptionId, sessionId
sdee.login

# print events every 1 second in JSON format
sdee.poll_events 1
