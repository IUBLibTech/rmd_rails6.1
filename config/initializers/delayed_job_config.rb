require AfrHelper, AtomFeedReaderTask, AvalonItemsHelper, JsonReaderHelper, JsonReaderTask

Delayed::Worker.destroy_failed_jobs = false
Delayed::Worker.sleep_delay = 15
Delayed::Worker.max_attempts = 2
Delayed::Worker.max_run_time = 72.hours
Delayed::Worker.read_ahead = 5
Delayed::Worker.default_queue_name = 'default'
Delayed::Worker.delay_jobs = !Rails.env.test?
Delayed::Worker.raise_signal_exceptions = :term
Delayed::Worker.logger = Logger.new(File.join(Rails.root, 'log', 'delayed_job.log'))

AtomFeedReaderTask.schedule!
JsonReaderTask.schedule!