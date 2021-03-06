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
require "#{File.dirname(__FILE__)}/conversions.rb"

module Calendrical
  class Calendar
    class UnknownLunarPhase < StandardError; end
    Date = Struct.new(:year, :month, :day)
  
    attr_accessor :elements
    delegate :day, :month, :year, to: :elements
    delegate :first, :last, :begin, :end, :each, :each_with_index, :step, :select, to: :range
  
    using Calendrical::Numeric

    include Enumerable
    include Comparable
    include Calendrical::Mpf
    include Calendrical::Epoch
    extend  Calendrical::Epoch
    include Calendrical::Base
    include Calendrical::Days
    include Calendrical::Months
    include Calendrical::Astro
    include Calendrical::Kday  
    include Calendrical::Astro::Solar
    include Calendrical::Astro::Lunar
    include Calendrical::Conversions

    def self.[](*args)
      new(*args)
    end
  
    def initialize(*args)
      args = [::Date.today] unless args.present?
      if args.first.is_a?(::Date)
        set_fixed(::Calendar::Gregorian::Date[args.first.year, args.first.month, args.first.day].to_fixed)
        set_elements(to_calendar(self.fixed))
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
      validate_date!
    end
  
    # TODO mirror the options in native class Date as appropriate
    # Defaults to inspect - better to implement the appropriate 
    # output per calendar
    def to_s(type = :short)
      inspect
    end
    
    def range
      @range ||= self..self
    end
  
    def days
      # Date difference + the initial day
      @days ||= range.last - range.first + 1
    end
  
    # Default convert ranges (years, quarters, months, weeks) to the fixed date of the start of the range
    def to_fixed
      range.present? ? range.first.fixed : fixed
    end
  
    def to_date
      to_gregorian.to_date
    end
  
    # Convert a fixed date to the current calendar
    def to_calendar(*args)
      raise "Implement to_calendar in inherited class"
    end

    def to_gregorian
      if range.present?
        if range.first == range.last
          ::Calendar::Gregorian::Date[range.first.to_fixed]
        else
          ::Calendar::Gregorian::Date[range.first.to_fixed]..::Calendar::Gregorian::Date[range.last.to_fixed]
        end
      else
        ::Calendar::Gregorian::Date[to_fixed]
      end
    end

    def +(other)
      date(self.fixed + other.to_i)
    end
  
    def -(other)
      if other.class < Calendar
        # Difference two dates in any calendar is an integer
        self.fixed - other.fixed
      elsif other.respond_to? :to_date
        # Difference between two dates is an integer 
        self.fixed - Gregorian::Date[other.to_date].fixed
      else
        # Anything else we subtract the number of days from a date and return a date
        date(self.fixed - other.to_i)
      end
    end
  
    def <=>(other)
      self.fixed <=> other.fixed
    end
  
    def succ
      self + 1
    end

    def fixed
      @fixed ||= self.to_fixed
    end
    alias :to_i :fixed
  
    def fixed=(f)
      @fixed = f
    end
  
    # Epoch is a class methods on each Calendar
    def epoch
      self.class.epoch
    end

    def quarters_in_year
      4
    end

    def months_in_year
      12
    end
    
    def days_in_week
      7
    end
    
    def weekdays
      select {|d| d.day_of_week >= MONDAY && d.day_of_week <= FRIDAY}
    end
    
    def weekends
      select {|d| d.day_of_week == SATURDAY || d.day_of_week == SUNDAY}
    end
    
    def days_of_week(day)
      (first_kday(day)..last).step(7).to_a
    end
    
    def sunrise(location = GREENWICH, date = self.fixed)
      Calendrical::Moment.new(super, location)
    end

    def sunset(location = GREENWICH, date = self.fixed)
      Calendrical::Moment.new(super, location)
    end

    # Solstice
    def december_solstice(location = GREENWICH, g_year = self.year)
      Calendrical::Moment.new(super, location)
    end
  
    def june_solstice(location = GREENHICH, g_year = self.year)
      Calendrical::Moment.new(super, location)
    end
  
    # Equinox
    def march_equinox(location = GREENWICH, g_year = self.year)
      Calendrical::Moment.new(super, location)
    end
  
    def september_equinox(location = GREENWICH, g_year = self.year)
      Calendrical::Moment.new(super, location)
    end
  
    # Moonrise
    def moonrise(location = GREENWICH, date = self.fixed)
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
        raise(Calendrical::UnknownLunarPhase, "Unknown lunar phase angle #{phase}.")
      end                    
    end
  
    # Distance in meters
    def lunar_distance(tee = self.fixed)
      super
    end

    # see lines 1250-1266 in calendrica-3.0.cl
    # Return the list of the fixed dates of Calendar month 'c_month', day
    # 'c_day' that occur in Gregorian year 'g_year'.
    def in_gregorian(c_month = self.month, c_day = self.day, g_year = self.year)
      jan1 = Gregorian::Year[g_year].new_year.fixed
      y    = to_calendar(jan1).year
      y_prime = (y == -1) ? 1 : (y + 1)
      date1 = date(y, c_month, c_day).fixed
      date2 = date(y_prime, c_month, c_day).fixed
      list_range(date1..date2, Gregorian::Year[g_year].year_range)
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
  
    # Implement in concrete class
    def validate_date!
    
    end
  
  end
end