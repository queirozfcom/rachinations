Rachinations
====================
[![Build Status](https://travis-ci.org/queirozfcom/rachinations.svg?branch=master)](https://travis-ci.org/queirozfcom/rachinations?branch=master)
[![Code Climate](https://codeclimate.com/github/queirozfcom/rachinations.png)](https://codeclimate.com/github/queirozfcom/rachinations)
[![Coverage Status](https://coveralls.io/repos/queirozfcom/rachinations/badge.png?branch=master)](https://coveralls.io/r/queirozfcom/rachinations?branch=master)
[![Gem Version](https://badge.fury.io/rb/rachinations.svg)](http://badge.fury.io/rb/rachinations)

This is a port of Dr. J. Dormans' [Machinations framework](http://www.jorisdormans.nl/machinations/) into Ruby.

It provides a Ruby-based DSL to enable game designers to create and also test tentative game designs and/or prototypes.

## Contents

- Classes to model the domain
- Tests
- A simple DSL (Domain-specific language) whose objective is to enable anyone to write Machinations diagrams, run them, obtain metrics, compose subdiagrams and so on.

## Installation Guide

Rachinations is written in Ruby so you need to have Ruby installed on your system. You only need 5 minutes to get it to work:

**Linux**

  The best way to install Ruby on a Linux-based machine is probably RVM. [Instructions on how to install RVM on Linux here](http://queirozf.com/entries/tutorial-and-examples-on-how-to-use-rvm-on-linux)

  Once Ruby is installed, you just need to install the rachinations **gem**. The process is straightforward:

  ```
  $ gem install rachinations
  ```

**Windows**

  - **Installation**

  On Windows, the best way to get up and running with Ruby is probably using the [RubyInstaller for Windows](http://rubyinstaller.org/)

  Please note that Rachinations requires at least Ruby **version 2.1** to work.

  If you have never used Ruby before, I recommend you tick the following two boxes, as per the following image:

  ![installing_ruby_on_windows](http://i.imgur.com/Y0u1ZzN.png)

  - **Veryfing that the installation worked**

  Once Ruby is installed, open a **command prompt** and type `ruby -v` just to see if everything worked.

  You should see something like this (details may vary slightly)

  ```
  > ruby -v
  ruby 2.1.5p273 (2014-11-13 revision 48405) [x64-mingw32]
  ```

  - **Configuring rubygems and installing the library**

  Once that's done, we'll configure `gem` (Ruby's package manager) to address a well known problem that has to do with certificates on Windows. More info [here](http://stackoverflow.com/questions/9962051/could-not-find-a-valid-gem-in-any-repository-rubygame-and-others) and [here](http://help.rubygems.org/discussions/problems/19761-could-not-find-a-valid-gem).

  On the command prompt, do this:

  ```
  > gem sources -r https://rubygems.org
  ```
  and

  ```
  > gem sources -a http://rubygems.org
  https://rubygems.org is recommended for security

  Do you want to add this insecure source? [yn] y
  http://rubygems.org added to sources
  ```

  After you've done the last step (which adds a new source for gems to be fetched from), then you can install the gem proper:

  ```
  > gem install rachinations
  ```
  (you might see a few error messages, but don't worry)

## Usage

All you need to do is write your diagram in a file whose name ends in `.rb` and run it using the `ruby` command.

### Examples

- **Simplest possible example**

 ```ruby
 require 'rachinations'

 # this is a simple diagram with a single pool with
 # 5 resources
 d=diagram 'simplest_diagram' do
     pool initial_value: 5
 end

 # and execute it for 10 rounds
 d.run 10
 ```

 Save this code into a file (say, `static_diagram.rb`) and run it like this:

 ```
 $ ruby static_diagram.rb
 ```

- **Example 1**

 ```ruby
 require 'rachinations'

 diagram 'example_1' do
     source 's1', :automatic
     pool 'p1'
     pool 'p2', :automatic
     edge from: 's1', to: 'p1'
     edge from: 'p1', to: 'p2'
 end
 ```

- **Example 2**

 ```ruby
 require 'rachinations'

 diagram 'example_2' do
     source 's1'
     pool 'p1'
     converter 'c1', :automatic
     pool 'p2'
     pool 'p3'
     edge from: 's1', to: 'p1'
     edge from: 'p1', to: 'c1'
     edge from: 'c1', to: 'p2'
     edge from: 'c1', to: 'p3'
 end
 ```

- **Example 3**

 ```ruby
 require 'rachinations'

 diagram 'example_3' do
     source 's1'
     gate 'g1', :probabilistic
     pool 'p1'
     pool 'p2'
     pool 'p3'
     sink 's2', :automatic, condition: expr{ p2.resource_count > 30 }
     edge from: 's1', to: 'g1'
     edge from: 'g1', to: 'p1'
     edge 2, from: 'g1', to: 'p2'
     edge from: 'g1', to: 'p3'
     edge from: 'p3', to 's2'
 end
 ```

- **Example 4**

 ```ruby
 require 'rachinations'

 diagram 'example_4' do
     source 's1'
     pool 'p1', triggers: 's2'
     source 's2', :passive
     pool 'p2'
     edge from: 's1', to: 'p1'
     edge from: 's2', to: 'p2'
 end
 ```

- **Example 4, alternative version**

 This amounts to the same diagram as the one defined in Example 4, but uses a different mechanism for defining triggers between nodes.

 ```ruby
 require 'rachinations'

 diagram 'example_4_alternative' do
     source 's1'
     pool 'p1'
     source 's2', :passive, triggered_by: 'p1'
     pool 'p2'
     edge from: 's1', to: 'p1'
     edge from: 's2', to: 'p2'
 end
 ```

### Full DSL specification
 **TODO**




