require "calendrical/version"
require "calendrical/calendar"
require "calendrical/calendars/gregorian.rb"
require "calendrical/calendars/julian.rb"

if defined?(I18n)
  I18n.load_path += Dir.glob( File.dirname(__FILE__) + "/locales/**/*.{rb,yml}" ) 
end

module Calendrical

  
end
