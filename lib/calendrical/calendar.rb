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
  include Calendrical::Eccesiastical
  
  attr_accessor :date_elements
  delegate :day, :month, :year, to: :date_elements

  def self.[](*args)
    new(*args)
  end
  
  def initialize(*args)
    if args.first.is_a?(Date)
      @date_elements = DateStruct.new(args.first.year, args.first.month, args.first.day)
    elsif args.first.is_a? self.class
      @date_elements = args.first.date_elements
    elsif args.first.is_a?(Fixnum) && args.length == 1
      @date_elements = to_calendar(args.first)
    else
      @date_elements = DateStruct.new(*args)
    end
  end
  
  def date(*args)
    self.class[*args]
  end
  
end