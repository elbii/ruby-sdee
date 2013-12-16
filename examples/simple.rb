$LOAD_PATH << './lib'
require './lib/sdee'

# create new SDEE connection
client = SDEE::Client.new(
  host: 'localhost',
  user: 'user',
  password: 'pass')

puts "client initialized"

# start polling
client.start_polling
