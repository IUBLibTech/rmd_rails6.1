namespace :recurring do
  desc 'Runs the background process that reads the Avalon atom feed'
  task read_atom_feed: :environment do
    # schedules the atom feed reader background process to run
    AtomFeedReaderTask::LOGGER.info "Attempting to schedule AtomFeedReader"
    begin
      AtomFeedReaderTask.schedule!
      AtomFeedReaderTask::LOGGER.info "AtomFeedReaderTask should be scheduled"
      AtomFeedReaderTask::LOGGER.info("DelayedJobs saved to the database: #{Delayed::Job.all.size}")
    rescue Exception => e
      AtomFeedReaderTask::LOGGER.error e.message
      AtomFeedReaderTask::LOGGER.error e.backtrace.join('\n')
    end
  end

  desc 'Runs the background process that parses JSON records in MCO'
  task parse_json: :environment do
    # schedules the JSON reader background process to run
    JsonReaderTask.schedule!
  end

  desc 'Runs background process to check whether RMD items with access determination but not yet published in MCO, have been pulished in MCO'
  task check_published: :environment do

  end


  desc 'Tests whether or not I can requeue new jobs within the job'
  task test: :environment do

  end
end