namespace :recurring do
  desc 'Runs the background process that reads the Avalon atom feed'
  task read_atom_feed: :environment do
    # schedules the atom feed reader background process to run
    AtomFeedReaderTask::LOGGER.info "Attempting to schedule AtomFeedReader"
    begin
      AtomFeedReaderTask.schedule!
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
end