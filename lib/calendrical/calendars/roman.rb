class Roman::Calendar < Julian::Calendar
  # see lines 1113-1116 in calendrica-3.0.cl
  KALENDS = 1
  NONES   = 2
  IDES    = 3
  
  # see lines 1047-1050 in calendrica-3.0.cl
  # Retrun a negative value to indicate a BCE Julian year."""
  def bce(n)
    return -n
  end

  # see lines 1052-1055 in calendrica-3.0.cl
  def ce(n)
    n
  end
  
  # see lines 1231-1234 in calendrica-3.0.cl
  def year_rome_founded
    bce(753)
  end
  
  # see lines 1128-1131 in calendrica-3.0.cl
  # Return the Roman date data structure.
  def roman_date(year, month, event, count, leap)
    [year, month, event, count, leap]
  end

  # see lines 1133-1135 in calendrica-3.0.cl
  # Return the year of Roman date 'date'.
  def roman_year(date)
    date[0]
  end

  # see lines 1137-1139 in calendrica-3.0.cl
  # Return the month of Roman date 'date'.
  def roman_month(date)
    date[1]
  end

  # see lines 1141-1143 in calendrica-3.0.cl
  #Return the event of Roman date 'date'.
  def roman_event(date)
    date[2]
  end

  # see lines 1145-1147 in calendrica-3.0.cl
  # Return the count of Roman date 'date'.
  def roman_count(date)
    date[3]
  end

  # see lines 1149-1151 in calendrica-3.0.cl
  # Return the leap indicator of Roman date 'date'."""
  def roman_leap(date)
    date[4]
  end

  # see lines 1153-1158 in calendrica-3.0.cl
  # Return the date of the Ides in Roman month 'month'."""
  def ides_of_month(month)
    [MARCH, MAY, JULY, OCTOBER].include?(month) ? 15 : 13
  end

  # see lines 1160-1163 in calendrica-3.0.cl
  # Return the date of Nones in Roman month 'month'."""
  def nones_of_month(month)
    ides_of_month(month) - 8
  end

  # see lines 1165-1191 in calendrica-3.0.cl
  # Return the fixed date corresponding to Roman date 'r_date'."""
  def fixed_from_roman(r_date)
      leap  = roman_leap(r_date)
      count = roman_count(r_date)
      event = roman_event(r_date)
      month = roman_month(r_date)
      year  = roman_year(r_date)
      return ({KALENDS: to_fixed(julian_date(year, month, 1)),
               NONES:   to_fixed(date(year, month, nones_of_month(month))),
               IDES:    to_fixed(date(year, month, ides_of_month(month)))
               }[event] -
              count +
              ((leap_year?(year) && (month == MARCH) && (event == KALENDS) && (16 >= count >= 6)) ? 0 : 1 +
              (leap ? 1 : 0)))
  end


  # see lines 1193-1229 in calendrica-3.0.cl
  # Return the Roman name corresponding to fixed date 'date'."""
  def roman_from_fixed(f_date)
    j_date = julian_from_fixed(f_date)
    month  = standard_month(j_date)
    day    = standard_day(j_date)
    year   = standard_year(j_date)
    month_prime = amod(1 + month, 12)
    year_prime  = (if month_prime != 1
                    year
                  elsif year != -1
                    year + 1
                  else
                    1
                  end)
    kalends1 = fixed_from_roman(roman_date(year_prime, month_prime, KALENDS, 1, False))

    res = if day == 1
      roman_date(year, month, KALENDS, 1, False)
    elsif day <= nones_of_month(month):
      roman_date(year, month, NONES, nones_of_month(month)-day+1, False)
    elsif day <= ides_of_month(month):
      roman_date(year, month, IDES, ides_of_month(month)-day+1, False)
    elsif (month <> FEBRUARY) or not is_julian_leap_year(year):
      roman_date(year_prime, month_prime, KALENDS, kalends1 - date + 1, False)
    elsif day < 25:
      roman_date(year, MARCH, KALENDS, 30 - day, False)
    else
      roman_date(year, MARCH, KALENDS, 31 - day, day == 25)
    end
    return res
  end
  
  # see lines 1236-1241 in calendrica-3.0.cl
  # Return the Julian year equivalent to AUC year 'year'."""
  def julian_year_from_auc_year(year)
    1..(year - YEAR_ROME_FOUNDED).include?(year) ? (year + YEAR_ROME_FOUNDED - 1) : (year + YEAR_ROME_FOUNDED))
  end

  # see lines 1243-1248 in calendrica-3.0.cl
  # Return the AUC year equivalent to Julian year 'year'."""
  def auc_year_from_julian_year(year)
    (YEAR_ROME_FOUNDED..-1).include?(year) ? (year - YEAR_ROME_FOUNDED - 1) : (year - YEAR_ROME_FOUNDED)
  end

end