class User < ApplicationRecord
  attr_accessor :ldap_lookup_key
  include LDAPGroupsLookup::Behavior
  include Nokogiri



  # FIXME: for now simply check usernames against this array for determining if a given user is a copyright librarian
  COPYRIGHT_LIBRARIANS = %w(nazapant admjaa)
  WEB_ADMINS = %w(shmichae jaalbrec mcwhitak gfitzwat)

  scope :user_collections, -> {
    AvalonItem.where(pod_unit: UnitsHelper.human_readable_units_search(User.current_username)).pluck(:collection).distinct.sort
  }
  scope :user_collection_ais, -> (collection) {
    AvalonItem.where(pod_unit: UnitsHelper.human_readable_units_search(User.current_username), collection: collection)
  }

  def self.authenticate(username)
    # FIXME: update this to check against ADS groups and unit access
    return !username.nil?
  end

  def self.current_username=(user)
    Thread.current[:current_username] = user
  end

  def self.current_username
    user_string = Thread.current[:current_username].to_s
    user_string.blank? ? "UNAVAILABLE" : user_string
  end

  def self.ldap_lookup
    u = User.new
    u.ldap_lookup_key = User.current_username
    u.ldap_groups
    u
  end

  def self.copyright_librarian?(username)
    COPYRIGHT_LIBRARIANS.include? username
  end
  def self.collection_manager?(username)
    ! self.copyright_librarian?(username)
  end

  def self.current_user_copyright_librarian?
    COPYRIGHT_LIBRARIANS.include? current_username
  end

  def self.belongs_to_unit?(unit)
    user = User.where(username: current_username).first
    user.blank? ? false : user[unit.downcase.parameterize.underscore.to_sym]
  end

  # takes a user and depending on whether they exist and have the ignore_ads flag set to true will do either of the
  # following:
  # if the user does not have an entry in the database or an entry does exists but ignore_ads is false, does an LDAP
  # lookup to see what units the user can access at login (this may have changed since last login). Saves this to the
  # user record.
  #
  # OR
  #
  # If the user exists and ignore_ads is true, returns whatever is currently set on the user object. This is the
  # mechanism by which a user can be given access to specific units for testing purposes
  #
  # FIXME: remove this code in production use?
  def self.save_session_user(username)
    u = User.where(username: username).first
    if u.nil? # this could be the first time a user has logged into RMD, or someone who is not authorized but trying
      u = User.new(username: username)
    elsif u.ignore_ads # don't recalculate ADS groups, rely on what is in the database
      return u
    end
    units = UnitsHelper.calc_user_ads_units(username)
    units.each do |unit|
      u.send("#{unit.underscore}=", true)
    end
    u.save!
  end

  # Builds the where portion of the users table that corresponds ONLY to unit membership fields of the user table
  # For instance "(b_iulmia = true AND b_aaamc = true)"
  def self.user_where_claus
    # we should always get a username from this table, if not raise an error
    user = User.where(username: current_username).first
    raise "Unknown user #{current_username} - how is this possible" if user.nil?
    where = ""
    UnitsHelper.units.each do |u|
      if user.public_send u.underscore
        where << " AND " if where.length > 0
        where << " #{u.underscore} = true"
      end
    end
    where
  end

  def self.ldap_test
    ldap = Net::LDAP.new(
      host: 'ads.iu.edu',
      port: 636,
      encryption: {
        method: :simple_tls,
        tls_options: OpenSSL::SSL::SSLContext::DEFAULT_PARAMS,
      },
      auth: {
        method: :simple,
        username: "#{Rails.application.credentials[:ldap_username]}",
        password: "#{Rails.application.credentials[:ldap_password]}"
      }
    )
    begin
      ldap.bind
    rescue Exception => e
      puts e.message
      puts e.backtrace.join("\n")
    end
  end

end
