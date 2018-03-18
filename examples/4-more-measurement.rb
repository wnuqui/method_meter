require_relative 'helper'

MethodMeter.observe Raiser

MethodMeter.measure!('key-1') do
  Raiser.do 1, 5

  Raiser.do 5, 5

  Raiser.do 5, 500
end

MethodMeter.measure!('key-2') do
  Raiser.do 1, 5

  Raiser.do 5, 5

  Raiser.do 5, 500
end

ap MethodMeter.data
ap MethodMeter.measurement