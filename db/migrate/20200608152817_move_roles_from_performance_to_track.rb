class MoveRolesFromPerformanceToTrack < ActiveRecord::Migration[4.2]
  # "Performer (P)", "Conductor (P)", "Interviewee (P)"
  def change
    add_column :track_contributor_people, :interviewer, :boolean
    remove_column :performance_contributor_people, :interviewer, :boolean
    add_column :track_contributor_people, :performer, :boolean
    remove_column :performance_contributor_people, :performer, :boolean
    add_column :track_contributor_people, :conductor, :boolean
    remove_column :performance_contributor_people, :conductor, :boolean
    add_column :track_contributor_people, :interviewee, :boolean
    remove_column :performance_contributor_people, :interviewee, :boolean
  end
end
