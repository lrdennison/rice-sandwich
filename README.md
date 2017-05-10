# rice-sandwich
Generate C++ boilerplate for Ruby's Rice interface

# Motivation

Occasionally I have to accelerate my Ruby code with C++.  Rice is a
large help but still requires fairly repetitious C++ code.  Simple
structure members (like an int) require writing setters and getters
and then registering those setter/getters.  This became even worse
when I adopted the Handle/Body idiom.  Explicitly writing the
delegation routines was a bit much.

The idea is to use a Domain Specific Language (written in Ruby of
course) to handle most of the tedious work.

## Example of using the DSL

```ruby
RiceSandwich::make do
  attr :int, :x
  attr :float, :y

  method :sum # user defined method

  write_files
end
```
