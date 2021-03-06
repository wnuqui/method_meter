require_relative 'helper'

# values set will not be profiled/instrumented
MethodMeter.exceptions = [:perform_addition]

MethodMeter.observe Arithmeter

MethodMeter.measure!('key-1') do
  arithmeter = Arithmeter.new
  arithmeter.add 1, 3

  Arithmeter.sum 1, 3

  arithmeter = Arithmeter.new
  arithmeter.add 4, 3

  Arithmeter.sum 4, 3
end

ap MethodMeter.data
ap MethodMeter.measurement