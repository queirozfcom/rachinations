rachinations
====================
[![Build Status](https://travis-ci.org/queirozfcom/rachinations.svg?branch=master)](https://travis-ci.org/queirozfcom/rachinations?branch=master)
[![Code Climate](https://codeclimate.com/github/queirozfcom/rachinations.png)](https://codeclimate.com/github/queirozfcom/rachinations)
[![Coverage Status](https://coveralls.io/repos/queirozfcom/rachinations/badge.png?branch=master)](https://coveralls.io/r/queirozfcom/rachinations?branch=master)
[![Gem Version](https://badge.fury.io/rb/rachinations.svg)](http://badge.fury.io/rb/rachinations)

### Introduction

This is a port of Dr. J. Dormans' Machinations framework into Ruby.

### Contents

- Classes to model the domain
- Tests
- A simple DSL (Domain-specific language) whose objective is to enable anyone to write Machinations diagrams, run them, obtain metrics, compose subdiagrams and so on.

### DSL Usage
- Simplest possible usage:
  - Install the `rachinations` gem and use it like this:
  
  ```ruby
  require 'rachinations'

  n=diagram 'my diagram' do
    node 's1',Source
    node 'p1', Pool
    edge 'e1', Edge, 's1','p1'
  end

  n.run!(5)
  
  p n.get_node("p1").resource_count
  #prints 5
  ```
