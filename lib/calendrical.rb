require "calendrical/version"
require "calendrical/calendar"
require "calendrical/calendars/ecclesiastical.rb"
require "calendrical/calendars/gregorian.rb"
require "calendrical/calendars/julian.rb"
require "calendrical/calendars/iso.rb"
require "calendrical/calendars/coptic.rb"
require "calendrical/calendars/egyptian.rb"
require "calendrical/calendars/armenian.rb"
require "calendrical/calendars/balinese.rb"
require "calendrical/calendars/etheopian.rb"
require "calendrical/calendars/french_revolutionary.rb"

if defined?(I18n)
  I18n.load_path += Dir.glob( File.dirname(__FILE__) + "/locales/**/*.{rb,yml}" ) 
end

module Calendrical

  
end
