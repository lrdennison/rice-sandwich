module RiceSandwich

  class Attribute
    attr_accessor :parent
    attr_accessor :type
    attr_accessor :name

    include Indent
    
    def initialize parent, type, name
      @parent = parent
      @type = type
      @name = name
    end
    

    def decl
      di + "#{type} #{name};" + eol
    end


    def setter
      "set_#{name}"
    end
    
    def getter
      "get_#{name}"
    end
    

    def setter_decl()
      di + "#{type} #{setter}(#{type} v);" + eol
    end

    def setter_impl()
      s = ""
      s += pi + "#{type} #{parent.handle_name}::#{setter}(#{type} v) {" + eol
      s += di + "(*this)->#{name} = v;" + eol
      s += di + "return (*this)->#{name};" + eol
      s += mi + "}" + eol
      s
    end

    def getter_decl()
      di + "#{type} #{getter}();" + eol
    end
    
    def getter_impl()
      s = ""
      s += pi + "#{type} #{parent.handle_name}::#{getter}() {" + eol
      s += di + "return (*this)->#{name};" + eol
      s += mi + "}" + eol
      s
    end

  end

    
end

