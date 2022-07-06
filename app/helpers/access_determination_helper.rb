module AccessDeterminationHelper
  DEFAULT_ACCESS = "Default IU Access - Not Reviewed"
  IU_ACCESS = "IU Access - Reviewed"
  WORLD_WIDE_ACCESS = "World Wide Access"
  RESTRICTED_ACCESS = "Restricted Access"
  RA_ETHICAL = "Restricted Access - Ethical"
  RA_LICENCE = "Restricted Access - Licence"
  RA_PRIVACY =  "Restricted Access - Privacy"

  ACCESS_DECISIONS = [DEFAULT_ACCESS, IU_ACCESS, WORLD_WIDE_ACCESS, RESTRICTED_ACCESS]
  ORDERED_ACCESS_DECISIONS = [RESTRICTED_ACCESS, IU_ACCESS, DEFAULT_ACCESS, WORLD_WIDE_ACCESS]
  # ACCESS_REASONS = {
  #   RESTRICTED_ACCESS => ['Ethical Considerations', 'Licensing Restrictions', 'Privacy Considerations'],
  #   DEFAULT_ACCESS => ['No Reasons For This....'],
  #   IU_ACCESS => ['Anything?'],
  #   WORLD_WIDE_ACCESS => ['IU Owned/Produced', 'License', 'Public Domain']
  # }

  RESTRICTED_ACCESS_REASONS = [:reason_ethical_privacy, :reason_feature_film, :reason_licensing_restriction ]
  IU_ACCESS_REASONS = [:reason_in_copyright]
  WORLD_WIDE_ACCESS_REASONS =[:reason_iu_owned_produced, :reason_license, :reason_public_domain]

  # default access is the highest rank so that it is omitted from subsequent access requests - any access determination
  # after the default value is considered 'reviewed'
  ACCESS_RANKING = {
    RESTRICTED_ACCESS => 1,
    IU_ACCESS => 2,
    WORLD_WIDE_ACCESS => 3,
    DEFAULT_ACCESS => 2
  }

  ACCESS_FROM_RANKING = {
    1 => "Restricted Access",
    2 => "IU Access",
    3 => "World Wide Access"
  }

  def self.avalon_access_level(access)
    raise "Unknown access level: #{access}" unless ACCESS_DECISIONS.include?(access)
    ACCESS_FROM_RANKING[ACCESS_RANKING[access]]
  end

  # compares access to bounding_access and returns true if and only if access is less restrictive or the same access
  # level as defined by the rankings in ACCESS_RANKING
  # FIXME: change this so that it only returns true/false based on whether the determination is more restrictive. Do NOT raise an exception
  def is_more_restrictive_than?(access, bounding_access)
    return true if bounding_access.nil? && ACCESS_DECISIONS.include?(access)
    raise "Invalid Access Determination: #{access}" unless ACCESS_DECISIONS.include?(access)
    raise "Invalid Access Determination: #{bounding_access}" unless ACCESS_DECISIONS.include?(bounding_access)
    ACCESS_RANKING[access] <= ACCESS_RANKING[bounding_access]
  end
end
