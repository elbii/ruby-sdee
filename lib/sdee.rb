require 'sdee/poller'
require 'sdee/alert'

module SDEE
  attr_accessor :poller, :events

  def initialize(options={})
    @poller = Poller.new(*options)

    # buffer to retain alerts, threads
    @events = @threads = []
  end

  def start_polling(num_threads=5)
    stop_polling unless @threads.empty?

    num_threads.times do
      @threads << Thread.new do
        @poller.poll
      end
    end
  end

  def stop_polling
    @threads.each { |thread| thread.terminate }
  end

  # Removes events from buffer
  def pop
    @events.delete
  end

  # Retrieves but doesn't remove events from buffer
  def get
    @events
  end
end
