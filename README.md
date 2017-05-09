# rice-sandwich
Generate boilerplate C++ for Ruby's Rice interface

# Motivation

Occasionally I have to accelerate my Ruby code with C++.  Rice is a
large help but still requires fairly repetitious C++ code.  Simple
structure members (like an int) require writing setters and getters
and then registering those setter/getters.

The idea is to use a Domain Specific Language (written in Ruby of
course) to handle most of the tedious work.
