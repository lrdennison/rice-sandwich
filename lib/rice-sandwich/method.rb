module RiceSandwich

  class Method

    attr_accessor :name
    attr_writer :ruby_name

    def initialize
      @name = nil
      @ruby_name = nil
    end

    def ruby_name
      return @name if @ruby_name.nil?
      return @ruby_name
    end
    
  end

end
