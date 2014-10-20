require "#{File.dirname(__FILE__)}/numeric.rb"
require "#{File.dirname(__FILE__)}/mpf.rb"
require "#{File.dirname(__FILE__)}/epoch.rb"
require "#{File.dirname(__FILE__)}/base.rb"
require "#{File.dirname(__FILE__)}/days.rb"
require "#{File.dirname(__FILE__)}/months.rb"
require "#{File.dirname(__FILE__)}/dates.rb"
require "#{File.dirname(__FILE__)}/seasons.rb"
require "#{File.dirname(__FILE__)}/kday.rb"
require "#{File.dirname(__FILE__)}/astro.rb"
require "#{File.dirname(__FILE__)}/moment.rb"

class Calendar
  class UnknownLunarPhase < StandardError; end
  Date = Struct.new(:year, :month, :day)
  
  attr_accessor :elements, :fixed
  delegate :day, :month, :year, to: :elements

  include Enumerable
  include Comparable
  include Calendrical::Mpf
  include Calendrical::Epoch
  extend  Calendrical::Epoch
  include Calendrical::Base
  include Calendrical::Days
  include Calendrical::Months
  include Calendrical::Astro
  include Calendrical::Astro::Solar
  include Calendrical::Astro::Lunar

  def self.[](*args)
    new(*args)
  end
  
  def initialize(*args)
    args = [::Date.today] unless args.present?
    if args.first.is_a?(::Date)
      set_elements(args.first.year, args.first.month, args.first.day)
    elsif args.first.is_a?(self.class)
      dup_instance(args.first)
    elsif args.first.respond_to?(:fixed)
      set_fixed(args.first.fixed)
      set_elements(to_calendar(self.fixed))      
    elsif args.first.is_a?(Fixnum) && args.length == 1
      set_fixed(args.first)
      set_elements(to_calendar(self.fixed))
    else
      set_elements(*args)
    end
  end
  
  # Epoch is a class methods on each Calendar
  def epoch
    self.class.epoch
  end
  
  def sunrise(location = GREENWHICH, date = self.fixed)
    Calendrical::Moment.new(super, location)
  end

  def sunset(location = GREENWHICH, date = self.fixed)
    Calendrical::Moment.new(super, location)
  end
  
  def moonrise(location = GREENWHICH, date = self.fixed)
    Calendrical::Moment.new(super, location)
  end
  
  # Solstice
  def december_solstice(location = GREENWHICH, g_year = self.year)
    Calendrical::Moment.new(super, location)
  end
  
  def june_solstice(location = GREENWHICH, g_year = self.year)
    Calendrical::Moment.new(super, location)
  end
  
  # Equinox
  def march_equinox(location = GREENWHICH, g_year = self.year)
    Calendrical::Moment.new(super, location)
  end
  
  def september_equinox(location = GREENWHICH, g_year = self.year)
    Calendrical::Moment.new(super, location)
  end

  # Phase of the moon in words
  def lunar_phase_name
    case (phase = lunar_phase(self.fixed).round)
    when 0..45
      defined?(I18n) ? I18n.t('moon_phase.new_moon')        : 'New Moon'
    when 46..90
      defined?(I18n) ? I18n.t('moon_phase.waxing_cresent')  : 'Waxing Cresent'      
    when 91..135
      defined?(I18n) ? I18n.t('moon_phase.first_quarter')   : 'First Quarter' 
    when 136..180
      defined?(I18n) ? I18n.t('moon_phase.waxing_gibbous')  : 'Waxing Gibbous'
    when 181..225
      defined?(I18n) ? I18n.t('moon_phase.full_moon')       : 'Full Moon'
    when 226..270
      defined?(I18n) ? I18n.t('moon_phase.waning_gibbous')  : 'Waning Gibbous'
    when 271..315
      defined?(I18n) ? I18n.t('moon_phase.last_quarter')    : 'Last Quarter'      
    when 316..360
      defined?(I18n) ? I18n.t('moon_phase.waning_crescent') : 'Waning Crescent'  
    else
      raise UnknownLunarPhase("Unknown lunar phase angle #{phase}.")
    end                    
  end
  
  # Distance in meters
  def lunar_distance(tee = self.fixed)
    super
  end
  
  def +(other)
    value = other.respond_to?(:fixed) ? other.fixed : other
    date(self.fixed + other)
  end
  
  def -(other)
    value = other.respond_to?(:fixed) ? other.fixed : other
    date(self.fixed - value)
  end
  
  def <=>(other)
    fixed <=> other.respond_to?(:fixed) ? other.fixed : other
  end
  
  def succ
    date(fixed + 1)
  end

  def fixed
    @fixed ||= self.to_fixed
  end
  alias :to_i :fixed
  
  def to_calendar(*args)
    raise "Implement to_calendar in inherited class"
  end
  
  def to_date
    to_gregorian.to_date
  end

  def to_gregorian
    GregorianDate[fixed]
  end
  
  def to_s(type = :short)
    inspect
  end
  
  # see lines 1250-1266 in calendrica-3.0.cl
  # Return the list of the fixed dates of Calendar month 'c_month', day
  # 'c_day' that occur in Gregorian year 'g_year'.
  def in_gregorian(c_month = self.month, c_day = self.day, g_year = self.year)
    jan1 = GregorianYear[g_year].new_year.fixed
    y    = to_calendar(jan1).year
    y_prime = (y == -1) ? 1 : (y + 1)
    date1 = date(y, c_month, c_day).fixed
    date2 = date(y_prime, c_month, c_day).fixed
    list_range(date1..date2, GregorianYear[g_year].year_range)
  end
  
protected
  # Copy the arguments to the date structure of the 
  # calendar class.  self.class::Date ensures we copy to the
  # calendar-specific structure if one exists
  def set_elements(*args)
    struct = self.class::Date
    if args.first.is_a?(struct) 
      @elements = args.first
    else
      @elements = struct.new unless @elements
      members = struct.members
      members.length.times do |i|
        @elements.send "#{members[i]}=", args[i]
      end
    end
  end
  
  def set_fixed(arg)
    @fixed = arg
  end
  
  def dup_instance(instance)
    self.fixed = instance.fixed
    self.elements = instance.elements
  end
  
  def date(*args)
    self.class[*args]
  end
  
end