class PodPhysicalObject < PodObject
  self.table_name = 'physical_objects'
  has_many :pod_digital_statuses, foreign_key: 'physical_object_id'
  belongs_to :pod_unit, foreign_key: 'unit_id'
  default_scope { includes (:pod_unit) }
end
