class PodUnit < PodObject
  self.table_name = 'units'
  has_many :pod_physical_objects
end