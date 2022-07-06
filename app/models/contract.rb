class Contract < ApplicationRecord
  belongs_to :avalon_item
  before_save :calc_edtf

  private
  def calc_edtf
    self.end_date = Date.edtf(self.date_edtf_text)
  end
end
