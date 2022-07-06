class RecordingTakeDownNotice < ApplicationRecord
  belongs_to :recording
  belongs_to :take_down_notice
end
