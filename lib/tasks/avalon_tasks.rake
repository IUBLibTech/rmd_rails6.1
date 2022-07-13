namespace :recurring do
  desc 'Runs the background process that reads the Avalon atom feed'
  task read_atom_feed: :environment do
    # schedules the atom feed reader background process to run
    AtomFeedReaderTask.schedule!
  end

  desc 'Runs the background process that parses JSON records in MCO'
  task parse_json: :environment do
    # schedules the JSON reader background process to run
    JsonReaderTask.schedule!
  end
end