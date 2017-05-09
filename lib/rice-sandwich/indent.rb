module RiceSandwich

  module Indent

    $indent = 0
    
    def di
      s = ""
      $indent.times do
        s += "  "
      end
      s
    end
    
    def pi
      s = di
      $indent += 1
      s
    end

    def mi
      $indent -= 1
      s = di
      s
    end

    def eol
      "\n"
    end


    def dquote s
      '"' + s.to_s + '"'
    end


    def guard token, &block
      s = ""
      s += "#ifndef #{token}" + eol
      s += "#define #{token}" + eol
      s += block.call
      s += "#endif" + eol
      s
    end
    


  end
  
end
