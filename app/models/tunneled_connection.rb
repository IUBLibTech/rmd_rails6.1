require 'net/ssh'

module TunneledConnection

  def self.connect
    Net::SSH::Gateway.new("#{Rails.application.credentials[:tunnel_host]}", Rails.application.credentials =[:tunnel_username], keys: ['certificate.pem']).open("#{Rails.application.credentials[:remote_hostname]}", 3306, 3307)
  end

end