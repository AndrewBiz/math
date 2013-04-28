#!/usr/bin/env ruby -U
# encoding: UTF-8
# (с) ANB Andrew Bizyaev Андрей Бизяев 

print "x = "
x = STDIN.gets.to_f
puts "x = #{x}"
left = 7.0/4.0*x - 0.125*x + 32.0/9.0*x
right = -(7.0*x - (-3.0/18.0*x + 5))
puts "left = #{left}"
puts "right = #{right}"

