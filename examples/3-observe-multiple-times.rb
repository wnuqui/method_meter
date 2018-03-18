require_relative 'helper'

MethodMeter.observe Arithmeter

MethodMeter.measure!('key-1') do
  arithmeter = Arithmeter.new
  arithmeter.add 1, 3

  Arithmeter.sum 1, 3

  arithmeter = Arithmeter.new
  arithmeter.add 4, 3

  Arithmeter.sum 4, 3
end

MethodMeter.observe Arithmeter

MethodMeter.observe Arithmeter

MethodMeter.observe Arithmeter

MethodMeter.measure!('key-2') do
  arithmeter = Arithmeter.new
  arithmeter.add 100, 3000

  Arithmeter.sum 100, 3000

  arithmeter = Arithmeter.new
  arithmeter.add 400, 3000

  Arithmeter.sum 400, 3000
end

ap MethodMeter.data
ap MethodMeter.measurement