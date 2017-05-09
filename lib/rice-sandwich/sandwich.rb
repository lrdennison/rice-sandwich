module RiceSandwich

  
  def self.make &block
    w = Wrap.new
    w.instance_exec &block
  end
  
  
  class Wrap
    attr_accessor :class_name
    attr_accessor :attributes
    attr_accessor :methods

    attr_accessor :system_headers

    def initialize
      @attributes = Array.new
      @methods = Array.new
      @under = Array.new
      
      init_system_headers
    end

    
    def init_system_headers
      @system_headers = Array.new

      system_headers << "iostream"
      system_headers << "string"
      
      system_headers << "rice/Class.hpp"
      system_headers << "rice/String.hpp"
      system_headers << "rice/Data_Type.hpp"
      system_headers << "rice/Constructor.hpp"
    end


    include Indent

    
    # DSL
    
    def attr type, name
      attributes << Attribute.new( self, type, name)
    end


    def klass name
      @class_name = name.to_s
    end

    
    def under s
      @under << s.to_s
    end
    
    
    ############################################################
    
    def base_name
      "#{class_name}Base"
    end


    def handle_name
      "#{class_name}Handle"
    end


    def base_hpp
      guard "_#{base_name.snake_case}_hpp_".upcase do
        s = ""
        s += base_decl
        s
      end
    end

    

    def base_decl
      s = ""
      s += pi + "struct #{base_name} {" + eol
      attributes.each do |a|
        s += a.decl
      end

      s += mi + "};" + eol
      s
    end


    ############################################################


    def handle_hpp
      guard "_#{handle_name.snake_case}_hpp_".upcase do
        s = ""
        s += "#include " + dquote(class_name.snake_case + ".hpp") + eol
        s += handle_decl
        s
      end
    end

    

    def handle_decl
      s = ""
      s += pi + "struct #{handle_name} : public std::shared_ptr<#{class_name}> {" + eol

      s += eol
      s += di + "typedef std::shared_ptr<#{class_name}> Ptr;" + eol
      s += eol
      
      s += di + "// Constructors" + eol
      s += di + "#{handle_name}();" + eol
      s += di + "#{handle_name}(const #{handle_name} &other);" + eol
      s += di + "#{handle_name}(Ptr &other);" + eol
      s += di + "#{handle_name}(#{class_name} *obj);" + eol
      s += eol
      
      s += pi + "struct HandleConstructor {" + eol
      s += di + "static void construct(Rice::Object self)" + eol
      s += pi + "{" + eol
      s += di + "DATA_PTR(self.value()) = new #{handle_name}(new #{class_name}());" + eol
      s += mi + "}" + eol
      s += mi + "};" + eol

      s += eol
      s += di + "// Installs ruby binding" + eol
      s += di + "static void install();" + eol
      s += eol
      s += di + "// Make both the underlying object and the handle" + eol
      s += di + "static #{handle_name} make();" + eol

      s += eol
      s += di + "// Setters and getters" + eol
      attributes.each do |a|
        s += a.setter_decl
        s += a.getter_decl
      end

      s += mi + "};" + eol
      s
    end



    def handle_install
      s = ""
      s += di + "void #{handle_name}::install()" + eol
      s += pi + "{" + eol
      s += di + "using namespace Rice;" + eol + eol
      
      scope = ""
      if @under.count > 0 then
        s += di + "Module m;" + eol
        @under.each do |x|
          s += di + "m = #{scope}define_module(#{dquote(x)});" + eol
          scope = "m."
        end
      end
      
      
      s += di + "Rice::Data_Type<#{handle_name}> data_type = #{scope}define_class<#{handle_name}>(#{dquote(class_name)});" + eol

      s += di + "//data_type.define_constructor(Rice::Constructor<#{handle_name}>());" + eol
      s += di + "data_type.define_constructor(HandleConstructor());" + eol

      attributes.each do |a|
        s += di + "data_type.define_method(#{dquote(a.name)}, &#{handle_name}::#{a.getter});" + eol
        s += di + "data_type.define_method(#{dquote(a.name.to_s + "=")}, &#{handle_name}::#{a.setter});" + eol
      end
      
      s += mi + "}" + eol + eol
      s
    end
    

    def handle_cpp
      s = ""

      system_headers.each do |fn|
        s += "#include <#{fn}>" + eol
      end

      s += "#include " + dquote(handle_name.snake_case + ".hpp") + eol
      s += eol
      s += eol

      s += di + "#{handle_name}::#{handle_name}() {}" + eol
      s += di + "#{handle_name}::#{handle_name}(const #{handle_name} &other) : Ptr(other) {}" + eol
      s += di + "#{handle_name}::#{handle_name}(Ptr &other) : Ptr(other) {}" + eol
      s += di + "#{handle_name}::#{handle_name}(#{class_name} *obj) : Ptr(obj) {}" + eol

      s += handle_install
      
      attributes.each do |a|
        s += a.setter_impl
        s += a.getter_impl
      end

      s
    end


    def write_files
      File.write base_name.snake_case + ".hpp", base_hpp
      File.write handle_name.snake_case + ".hpp", handle_hpp
      File.write handle_name.snake_case + ".cpp", handle_cpp
    end
    

  end

    
end
