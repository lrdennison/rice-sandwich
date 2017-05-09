
class String

  def is_upper?
    self == self.upcase
  end

  def is_lower?
    self == self.downcase
  end

  def capitalize_first_char
    slice(0,1).capitalize + slice(1..-1)
  end

  def camel_case
    split('_').map{ |s| s.capitalize_first_char}.join
  end

  
  def snake_case

    # print "\n"
    s = self
    loop = 0
    while loop < 64 do
      loop = loop + 1
      break if s.is_upper?

      # print "snake: #{s}\n"

      md = /[a-z]([A-Z])/.match( s)
      if md then
        s1 = s[0..md.begin(1)-1]
        s2 = $1.downcase
        s3 = s[md.end(1)..-1]
        s = s1 + "_" + s2 + s3
        next
      end

      md = /([A-Z])/.match( s)
      if md then
        s = $` + $1.downcase + $'
        next
      end

      break
    end
    return s

    
    s = each_char.map do |c|
      if c.is_lower? then
        c
      else
        "_#{c.downcase}"
      end
    end.join

    if s[0] == "_" then
      s = slice(1..-1)
    end
    s
  end
end
