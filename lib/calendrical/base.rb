module Calendrical
  class InvalidQuarter < StandardError; end
  class InvalidMonth < StandardError; end
  class InvalidWeek < StandardError; end
  class UnknownLunarPhase < StandardError; end
  
  module Base

    # see lines 249-252 in calendrica-3.0.cl
    # m // n
    # The following
    #      from operator import floordiv as quotient
    # is not ok, the corresponding CL code
    # uses CL 'floor' which always returns an integer
    # (the floating point equivalent is 'ffloor'), while
    # 'quotient' from operator module (or corresponding //)
    # can return a float if at least one of the operands
    # is a float...so I redefine it (and 'floor' and 'round' as well: in CL
    # they always return an integer.)
    #
    # Ruby floor always returns an integer
    def quotient(m, n)
      (m / n).floor
    end
    
    # m % n   (this works as described in book for negative integres)
    # It is interesting to note that
    #    mod(1.5, 1)
    # returns the decimal part of 1.5, so 0.5; given a moment 'm'
    #    mod(m, 1)
    # returns the time of the day
    # Ruby mod behaves per the book
    # from operator import mod

    # see lines 254-257 in calendrica-3.0.cl
    # Return the same as a % b with b instead of 0.
    def amod(x, y)
      y + (x % -y)
    end
    
    # see lines 502-510 in calendrica-3.0.cl
    # Return those moments in list ell that occur in range 'range'.
    def list_range(ell, range)
      ell.select{|l| range.include?(l) }.compact
    end

    # see lines 482-485 in calendrica-3.0.cl
    # Return the range data structure."""
    def interval(t0, t1)
      t0..t1
    end
    
    # see lines 259-264 in calendrica-3.0.cl
    # Return first integer greater or equal to initial index, i,
    # such that condition, p, holds.
    def next_of(i, p)
      x = i
      while !p.call(x) do
        x += 1
      end
      x
    end

    # see lines 266-271 in calendrica-3.0.cl
    # Return last integer greater or equal to initial index, i,
    # such that condition, p, holds.
    def final_of(i, p)
      if not p.call(i)
        return i - 1  
      else 
        final_of(i+1, p)
      end
    end

    # see lines 273-281 in calendrica-3.0.cl
    # Return the sum of f(i) from i=k, k+1, ... till p(i) holds true or 0.
    # This is a tail recursive implementation.
    def summa(f, k, p)
      if not p.call(k) 
        return 0 
      else 
        f.call(k) + summa(f, k+1, p)
      end
    end

    # Return the sum of f(i) from i=k, k+1, ... till p(i) holds true or 0.
    # This is an implementation of the Summation formula from Kahan,
    # see Theorem 8 in Goldberg, David 'What Every Computer Scientist
    # Should Know About Floating-Point Arithmetic', ACM Computer Survey,
    # Vol. 23, No. 1, March 1991.
    def altsumma(f, k, p)
      if not p.call(k)
        return 0
      else
        s = f.call(k)
        c = 0
        j = k + 1
        while p.call(j) do
          y = f.call(j) - c
          t = s + y
          c = (t - s) - y
          s = t
          j += 1
        end
      end

      return s
    end

    # see lines 283-293 in calendrica-3.0.cl
    # Bisection search for x in [lo, hi] such that condition 'e' holds.
    # p determines when to go left.
    def binary_search(lo, hi, p, e)
      x = (lo + hi) / 2 
      if p.call(lo, hi)
        return x
      elsif e.call(x)
        return binary_search(lo, x, p, e)
      else
        return binary_search(x, hi, p, e)
      end
    end

    # see lines 295-302 in calendrica-3.0.cl

    # Find inverse of angular function 'f' at 'y' within interval [a,b].
    # Default precision is 0.00001
    def invert_angular(f, y, a, b, prec = 10**-5)
      binary_search(a, b,
        lambda{|l, h| ((h - l) <= prec)},
        lambda{|x| ((f.call(x) - y) % 360) < 180}
      )
    end
    
    #def invert_angular(f, y, a, b):
    #      from scipy.optimize import brentq
    #    return(brentq((lambda x: mod(f(x) - y), 360)), a, b, xtol=error)

    # see lines 304-313 in calendrica-3.0.cl
    # Return the sum of body 'b' for indices i1..in
    # running simultaneously thru lists l1..ln.
    # List 'l' is of the form [[i1 l1]..[in ln]]
    def sigma(l, b)
      # 'l' is a list of 'n' lists of the same lenght 'L' [l1, l2, l3, ...]
      # 'b' is a lambda with 'n' args
      # 'sigma' sums all 'L' applications of 'b' to the relevant tuple of args
      # >>> a = [ 1, 2, 3, 4]
      # >>> b = [ 5, 6, 7, 8]
      # >>> c = [ 9,10,11,12]
      # >>> l = [a,b,c]
      # >>> z = zip(*l)
      # >>> z
      # [(1, 5, 9), (2, 6, 10), (3, 7, 11), (4, 8, 12)]
      # >>> b = lambda x, y, z: x * y * z
      # >>> b(*z[0]) # apply b to first elem of i
      # 45
      # >>> temp = []
      # >>> z = zip(*l)
      # >>> for e in z: temp.append(b(*e))
      # >>> temp
      # [45, 120, 231, 384]
      # >>> from operator import add
      # >>> reduce(add, temp)
      # 780
      # return sum(b(*e) for e in zip(*l))
      # puts "Zipped: #{l.first.zip(*l[1..-1]).map{|x| b.call(*x)}}"
      l.first.zip(*l[1..-1]).map{|x| b.call(*x)}.sum
    end

    # see lines 315-321 in calendrica-3.0.cl
    # Calculate polynomial with coefficients 'a' at point x.
    # The polynomial is a[0] + a[1] * x + a[2] * x^2 + ...a[n-1]x^(n-1)
    # the result is
    # a[0] + x(a[1] + x(a[2] +...+ x(a[n-1])...)
    def poly(x, a)
      # This implementation is also known as Horner's Rule.
      n = a.length - 1
      p = a[n]
      for i in 1..n do
        p = p * x + a[n-i]
      end
      p
    end
  end
end