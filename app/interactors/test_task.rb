class TestTask
  include AfrHelper

  def perform
    LOGGER.info "I'm doing some work!"
    LOGGER.info "I need a nap..."
    sleep(15)
    LOGGER.info "I feel refreshed after that nap."
    new TestTask.delay.perform
  end

end