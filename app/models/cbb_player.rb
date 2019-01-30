class CbbPlayer < ApplicationRecord
  belongs_to :cbb_team
  has_many :cbb_records
end
