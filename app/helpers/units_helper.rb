module UnitsHelper
  # UnitsHelper abbreviations as defined by UnitsHelper.abbreviation in POD
  def self.units
    ["B-AAAI", "B-AAAMC", "B-AFRIST", "B-ALF", "B-ANTH", "B-ARCHIVES", "B-ASTR", "B-ATHBASKM", "B-ATHBASKW", "B-ATHFHOCKEY",
     "B-ATHFTBL", "B-ATHROWING", "B-ATHSOCCM", "B-ATHSOFTB", "B-ATHTENNM", "B-ATHVIDEO", "B-ATHVOLLW", "B-ATM", "B-BCC",
     "B-BFCA", "B-BUSSPEA", "B-CAC", "B-CDEL", "B-CEDIR", "B-CELCAR", "B-CELTIE", "B-CEUS", "B-CHEM", "B-CISAB", "B-CLACS",
     "B-CMCL", "B-CREOLE", "B-CSHM", "B-CYCLOTRN", "B-EASC", "B-EDUC", "B-EPPLEY", "B-FACILITY", "B-FINEARTS", "B-FOLKETHNO",
     "B-FRANKLIN", "B-GBL", "B-GEOLOGY", "B-GLBTSSSL", "B-GLEIM", "B-GLOBAL", "B-HPER", "B-IAS", "B-IAUNRC", "B-IBHA", "B-IPRC",
     "B-IUAM", "B-IULMIA", "B-JOURSCHL", "B-KINSEY", "B-LACASA", "B-LAW", "B-LIBERIA", "B-LIFESCI", "B-LILLY", "B-LING",
     "B-MATHERS", "B-MDP", "B-MUSBANDS", "B-MUSIC", "B-MUSOPERA", "B-MUSREC", "B-OID", "B-OPTMSCHL", "B-OPTOMTRY", "B-POLISH",
     "B-PSYCH", "B-RECSPORTS", "B-REEI", "B-RTVS", "B-SAGE", "B-SAVAIL", "B-SWAIN", "B-TAI", "B-THTR", "B-UNDRWATR",
     "B-UNIVCOMM", "B-WELLS", "B-WEST", "EA-ARCHIVES", "EA-ATHL", "I-ARCHIVES", "I-DENT", "I-LIBR-SCA", "I-RAYBRAD",
     "KO-ARCHIVES", "NW-ARCHIVES", "SB-ARCHIVES", "SB-PHYS", "SB-ULIB", "SE-ARCHIVES"]
  end

  # ADS groups by unit as defined by dark Avalon. MCO uses a different schema since recordings can belong to multiple collections.
  # These groups named by convention: "BL-LDLP-MDPI-MANAGERS-" prepended to the unit names defined in self.units
  def self.ads_groups
    ["BL-LDLP-MDPI-MANAGERS-B-AAAI", "BL-LDLP-MDPI-MANAGERS-B-AAAMC", "BL-LDLP-MDPI-MANAGERS-B-AFRIST", "BL-LDLP-MDPI-MANAGERS-B-ALF",
     "BL-LDLP-MDPI-MANAGERS-B-ANTH", "BL-LDLP-MDPI-MANAGERS-B-ARCHIVES", "BL-LDLP-MDPI-MANAGERS-B-ASTR", "BL-LDLP-MDPI-MANAGERS-B-ATHBASKM",
     "BL-LDLP-MDPI-MANAGERS-B-ATHBASKW", "BL-LDLP-MDPI-MANAGERS-B-ATHFHOCKEY", "BL-LDLP-MDPI-MANAGERS-B-ATHFTBL",
     "BL-LDLP-MDPI-MANAGERS-B-ATHROWING", "BL-LDLP-MDPI-MANAGERS-B-ATHSOCCM", "BL-LDLP-MDPI-MANAGERS-B-ATHSOFTB",
     "BL-LDLP-MDPI-MANAGERS-B-ATHTENNM", "BL-LDLP-MDPI-MANAGERS-B-ATHVIDEO", "BL-LDLP-MDPI-MANAGERS-B-ATHVOLLW",
     "BL-LDLP-MDPI-MANAGERS-B-ATM", "BL-LDLP-MDPI-MANAGERS-B-BCC", "BL-LDLP-MDPI-MANAGERS-B-BFCA", "BL-LDLP-MDPI-MANAGERS-B-BUSSPEA",
     "BL-LDLP-MDPI-MANAGERS-B-CAC", "BL-LDLP-MDPI-MANAGERS-B-CDEL", "BL-LDLP-MDPI-MANAGERS-B-CEDIR", "BL-LDLP-MDPI-MANAGERS-B-CELCAR",
     "BL-LDLP-MDPI-MANAGERS-B-CELTIE", "BL-LDLP-MDPI-MANAGERS-B-CEUS", "BL-LDLP-MDPI-MANAGERS-B-CHEM", "BL-LDLP-MDPI-MANAGERS-B-CISAB",
     "BL-LDLP-MDPI-MANAGERS-B-CLACS", "BL-LDLP-MDPI-MANAGERS-B-CMCL", "BL-LDLP-MDPI-MANAGERS-B-CREOLE", "BL-LDLP-MDPI-MANAGERS-B-CSHM",
     "BL-LDLP-MDPI-MANAGERS-B-CYCLOTRN", "BL-LDLP-MDPI-MANAGERS-B-EASC", "BL-LDLP-MDPI-MANAGERS-B-EDUC", "BL-LDLP-MDPI-MANAGERS-B-EPPLEY",
     "BL-LDLP-MDPI-MANAGERS-B-FACILITY", "BL-LDLP-MDPI-MANAGERS-B-FINEARTS", "BL-LDLP-MDPI-MANAGERS-B-FOLKETHNO",
     "BL-LDLP-MDPI-MANAGERS-B-FRANKLIN", "BL-LDLP-MDPI-MANAGERS-B-GBL", "BL-LDLP-MDPI-MANAGERS-B-GEOLOGY", "BL-LDLP-MDPI-MANAGERS-B-GLBTSSSL",
     "BL-LDLP-MDPI-MANAGERS-B-GLEIM", "BL-LDLP-MDPI-MANAGERS-B-GLOBAL", "BL-LDLP-MDPI-MANAGERS-B-HPER", "BL-LDLP-MDPI-MANAGERS-B-IAS",
     "BL-LDLP-MDPI-MANAGERS-B-IAUNRC", "BL-LDLP-MDPI-MANAGERS-B-IBHA", "BL-LDLP-MDPI-MANAGERS-B-IPRC", "BL-LDLP-MDPI-MANAGERS-B-IUAM",
     "BL-LDLP-MDPI-MANAGERS-B-IULMIA", "BL-LDLP-MDPI-MANAGERS-B-JOURSCHL", "BL-LDLP-MDPI-MANAGERS-B-KINSEY", "BL-LDLP-MDPI-MANAGERS-B-LACASA",
     "BL-LDLP-MDPI-MANAGERS-B-LAW",
     "BL-LDLP-MDPI-MANAGERS-B-LIBERIA", "BL-LDLP-MDPI-MANAGERS-B-LIFESCI", "BL-LDLP-MDPI-MANAGERS-B-LILLY", "BL-LDLP-MDPI-MANAGERS-B-LING",
     "BL-LDLP-MDPI-MANAGERS-B-MATHERS", "BL-LDLP-MDPI-MANAGERS-B-MDP", "BL-LDLP-MDPI-MANAGERS-B-MUSBANDS", "BL-LDLP-MDPI-MANAGERS-B-MUSIC",
     "BL-LDLP-MDPI-MANAGERS-B-MUSOPERA", "BL-LDLP-MDPI-MANAGERS-B-MUSREC", "BL-LDLP-MDPI-MANAGERS-B-OID", "BL-LDLP-MDPI-MANAGERS-B-OPTMSCHL",
     "BL-LDLP-MDPI-MANAGERS-B-OPTOMTRY", "BL-LDLP-MDPI-MANAGERS-B-POLISH", "BL-LDLP-MDPI-MANAGERS-B-PSYCH", "BL-LDLP-MDPI-MANAGERS-B-RECSPORTS",
     "BL-LDLP-MDPI-MANAGERS-B-REEI", "BL-LDLP-MDPI-MANAGERS-B-RTVS", "BL-LDLP-MDPI-MANAGERS-B-SAGE", "BL-LDLP-MDPI-MANAGERS-B-SAVAIL",
     "BL-LDLP-MDPI-MANAGERS-B-SWAIN", "BL-LDLP-MDPI-MANAGERS-B-TAI", "BL-LDLP-MDPI-MANAGERS-B-THTR", "BL-LDLP-MDPI-MANAGERS-B-UNDRWATR",
     "BL-LDLP-MDPI-MANAGERS-B-UNIVCOMM", "BL-LDLP-MDPI-MANAGERS-B-WELLS", "BL-LDLP-MDPI-MANAGERS-B-WEST", "BL-LDLP-MDPI-MANAGERS-EA-ARCHIVES",
     "BL-LDLP-MDPI-MANAGERS-EA-ATHL", "BL-LDLP-MDPI-MANAGERS-I-ARCHIVES", "BL-LDLP-MDPI-MANAGERS-I-DENT", "BL-LDLP-MDPI-MANAGERS-I-LIBR-SCA",
     "BL-LDLP-MDPI-MANAGERS-I-RAYBRAD", "BL-LDLP-MDPI-MANAGERS-KO-ARCHIVES", "BL-LDLP-MDPI-MANAGERS-NW-ARCHIVES", "BL-LDLP-MDPI-MANAGERS-SB-ARCHIVES",
     "BL-LDLP-MDPI-MANAGERS-SB-PHYS", "BL-LDLP-MDPI-MANAGERS-SB-ULIB", "BL-LDLP-MDPI-MANAGERS-SE-ARCHIVES"]
  end

  # given a user, retuns an array of Strings containing unit names that a user belongs to
  def self.human_readable_units
    human_readable_units_search(User.current_username)
  end

  def self.calc_user_ads_units(user)
    u = User.new
    if User.copyright_librarian? user
      return units
    else
      u.ldap_lookup_key = user
      belongs_to = u.ldap_groups
      accessible_groups = belongs_to & ads_groups
      units = []
      accessible_groups.each do |g|
        # remove the first 21 characters of the group name to get the unit name (BL-LDLP-MDPI-MANAGERS-)
        units << g[22...100]
      end
      units
    end
  end

  def self.unit_member?(username, unit)
    user = User.where(username: username).first
    user[unit.downcase.parameterize.underscore.to_sym]
  end

  def self.human_readable_units_search(username)
    user = User.where(username: username).first
    groups = []
    units.each do |u|
      groups << u if !user.blank? && user[u.downcase.parameterize.underscore.to_sym]
    end
    groups
  end

  def self.sql_where_claus(username)
    "pod_unit in (#{human_readable_units_search(username).join(', ')})"
  end

end
