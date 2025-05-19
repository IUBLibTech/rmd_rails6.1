class PastAccessDecision < ApplicationRecord
  belongs_to :avalon_item, inverse_of: :past_access_decisions
  after_create :set_current_access

  private
  def set_current_access
    avalon_item.update!(current_access_determination_id: self.id)
  end
end
