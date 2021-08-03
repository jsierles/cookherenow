require 'maxmind/geoip2'
path = "#{Rails.root}/db/GeoLite2-City.mmdb"
puts path
$geoip = MaxMind::GeoIP2::Reader.new(database: path) 

