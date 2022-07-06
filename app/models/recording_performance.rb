class RecordingPerformance < ApplicationRecord
  belongs_to :recording
  belongs_to :performance
  accepts_nested_attributes_for :performance
end
