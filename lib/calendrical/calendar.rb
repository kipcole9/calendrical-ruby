require "#{File.dirname(__FILE__)}/numeric.rb"
require "#{File.dirname(__FILE__)}/mpf.rb"
require "#{File.dirname(__FILE__)}/base.rb"
require "#{File.dirname(__FILE__)}/moment.rb"
require "#{File.dirname(__FILE__)}/days.rb"
require "#{File.dirname(__FILE__)}/dates.rb"
require "#{File.dirname(__FILE__)}/months.rb"
require "#{File.dirname(__FILE__)}/seasons.rb"
require "#{File.dirname(__FILE__)}/kday.rb"
require "#{File.dirname(__FILE__)}/astro.rb"
require "#{File.dirname(__FILE__)}/calendars/ecclesiastical.rb"

class Calendar
  class UnknownLunarPhase < StandardError; end
  DateStruct = Struct.new(:year, :month, :day)

  
  include Enumerable
  include Comparable
  include Calendrical::Base
  include Calendrical::Astro
  include Calendrical::Astro::Solar
  include Calendrical::Astro::Lunar
  include Calendrical::Days
  include Calendrical::Months
  include Calendrical::Mpf
    
  attr_accessor :date_elements, :fixed
  delegate :day, :month, :year, to: :date_elements

  def self.[](*args)
    new(*args)
  end
  
  def initialize(*args)
    if args.first.is_a?(Date)
      set_elements(args.first.year, args.first.month, args.first.day)
    elsif args.first.is_a?(self.class)
      dup_instance(args.first)
    elsif args.first.is_a?(Fixnum) && args.length == 1
      set_fixed(args.first)
      set_elements(self.to_calendar)
    else
      set_elements(*args)
    end
  end
  
  # Moment of sunset
  def sunset(location)
    super(self.fixed, location)
  end
  
  # Moment of sunrise
  def sunrise(location)
    super(self.fixed, location)
  end
  
  # Moment of moonrise
  def moonrise(location)
    super(self.fixed, location)
  end
  
  # Phase of the moon in degrees
  def lunar_phase
    super(self.fixed)
  end
  
  # Phase of the moon in words
  def lunar_phase_name
    case (phase = lunar_phase.round)
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
      raise UnknownLunarPhase("Unknown lunar phase angle #{phase}")
    end                    
  end
  
  # Distance in meters
  def lunar_distance
    super(self.fixed)
  end
  
  def +(other)
    date(self.fixed + other)
  end
  
  def -(other)
    value = other.respond_to?(:fixed) ? other.fixed : other
    self.fixed - value
  end
  
  def <=>(other)
    fixed <=> other.fixed
  end
  
  def succ
    date(fixed + 1)
  end

  def fixed
    @fixed ||= self.to_fixed
  end
  alias :to_i :fixed
  
  def to_calendar
    raise "Implement to_calendar in inherited class"
  end
  
  def to_date
    raise "Implement to_date in inherited class"
  end

protected
  def set_elements(*args)
    @date_elements = args
  end
  
  def set_fixed(arg)
    @fixed = arg
  end
  
  def dup_instance(instance)
    self.fixed = instance.fixed
    self.date_elements = instance.date_elements
  end
  
  def date(*args)
    self.class[*args]
  end
  
end