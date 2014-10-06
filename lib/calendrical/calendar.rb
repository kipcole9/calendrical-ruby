require "#{File.dirname(__FILE__)}/base.rb"
require "#{File.dirname(__FILE__)}/astro.rb"
require "#{File.dirname(__FILE__)}/days.rb"
require "#{File.dirname(__FILE__)}/months.rb"
require "#{File.dirname(__FILE__)}/numeric.rb"
require "#{File.dirname(__FILE__)}/calculations.rb"
require "#{File.dirname(__FILE__)}/calendars/ecclesiastical.rb"

class Calendar
  DateStruct = Struct.new(:year, :month, :day)
  
  include Calendrical::Base
  include Calendrical::Astro
  include Calendrical::Days
  include Calendrical::Months
  
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
  
  def fixed
    @fixed ||= self.to_fixed
  end
  
  def calendar
    self.to_calendar
  end
  
  def to_date
    raise "Implement to_date in inherited class"
  end
  
end