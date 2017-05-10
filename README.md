# rice-sandwich
Generate C++ boilerplate for Ruby's Rice interface

# Motivation

Occasionally I have to accelerate my Ruby code with C++.  Rice is a
large help but still requires fairly repetitious C++ code.  Simple
structure members (like an int) require writing setters and getters
and then registering those setter/getters.  This became even worse
when I adopted the Handle/Body idiom.  Explicitly writing the
delegation routines was a bit too much.

The idea is to use a Domain Specific Language (written in Ruby of
course) to handle most of the tedious work.

## Example of using the DSL

```ruby
RiceSandwich::make do
  klass :MyClass
  
  attr :int, :x
  attr :float, :y

  method :sum # user defined method

  write_files
end
```

RiceSandwich defines two new classes for you.  One is MyClassBase, the
other is MyClassHandle.  You still own the job of defining
implementing MyClass.

```c++
struct MyClass : MyClassBase
{
  MyClass() {
    x = 0;
    y = 0.0;
  }
  
  float sum() {
    return y+static_cast<float>(x);
  }
};
```

The MyClassHandle class is derived from std::shared_ptr<MyClass>.  You
can use it just like you'd use any other shared pointer.

MyClassHandle provides a static bind_to_ruby method.  You call this in
your extension's init routine.

# Integrating with MakeMakefile (mkmf-rice and extconf.rb)

The automatic Makefile generation has no hooks for built sources.  I
created a ruby function called build_sources:

```ruby
# This is build_sources.rb

require "rice-sandwich"

def build_sources

  $built_source_dir = File.expand_path('..', __FILE__)

  RiceSandwich::make do
    ...
  end
  
end
```

I then require and and execute this in my extconf.rb file.

Yes, there is a magic global variable here.  Sorry.  The extension
autobuilder builds out-of-source but cannot find source files anywhere
but the source directory.  The above setting of $built_source_dir
means the extra sources will be created in the same directory as the
build_sources script.

