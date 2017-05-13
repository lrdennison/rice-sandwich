# Synopsis

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

## The Handle/Body pattern

Note: this is also referred to as the _pointer-to-implementation_ design pattern.

When writing C++ that plays nicely with Ruby, you can find that your
code is using relatively simple objects that have pointers to other
simple objects.  While Rice is really useful, one area that is
problematic is that lack of integration with Ruby's garbage collector.
A solution is to use smart pointers (C++ std::shared_ptr) pretty much
everywhere.

In order for this to work, the C++ class being registered with Ruby
isn't the implementation, it is the smart pointer (aka Handle).  Rice
has nice ways of registering methods on a class but doesn't seem to
understand delegating through a smart pointer.  One has to have
delegation methods defined in the handle class so that the calls are
forwarded to the implementation class.

## How does Rice-sandwich help?

Using a simple description, rice-sandwich generates C++ code for both
a Base class and a Handle class.  One writes an implementation class
which is derived from the Base class and whose methods are called by
the Handle class.  The implementation is "sandwiched" between the Base
and Handle.

The base class contains just the Ruby-accessible data members (aka
attributes) for the class.  Setter and getter methods are placed in
the Handle class.

The Handle class is derived from std::shared_ptr<>.  As mentioned, it
has the accessor methods plus delegates for the implementation
methods.  The method delegates are constructed using a bit of template
hackery so that one doesn't need the method signature in the DSL, just
the method name.

The Handle class defines the static member function _bind_to_ruby()_.
This makes all of the Rice registration calls in one handy place.

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

# The Handle class

## Constructors

The default C++ Handle constructor results in a nullptr.  This usually
what you want in C++.  However, when you call _new_ in Ruby, you want
the backing implementation to be instantiated.

Rice uses a Constructor object in setting up the Ruby binding.
RiceSandwich defines a construction class within the Handle class that
instantiates the implementation.  Calling .new on your Ruby class
thus works as expected.

## ::make

The Handle class provides a static _make_ method as convenience.


# DSL

## Keywords

* under
* klass
* attr
* method

### under

```ruby
under :MyModule
```

The class will be registered under module *MyModule*.

### klass


```ruby
klass :MyClass
```

The name of the class being defined.

### attr


```ruby
attr :int, :my_int
attr :MyClassHandle, :handle_to_another_object
```

Defines an attribute.

### method

```ruby
method :my_method
method :my_method, :ruby_method_name
method :array_reader, :[]
method :array_writer, :[]=
```

Binds a user-defined method.  It takes an optional argument for the ruby method name.

## Variables

* system_headers
* headers

### system_headers

Shift in any extra system headers you need included.

```ruby
system_headers << "some_system_header.hpp"
```

### headers

Shift in any extra user headers you need included.

```ruby
headers << "some_user_header.hpp"
```


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

