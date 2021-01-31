require 'method_meter/version'

require 'active_support'
require 'active_support/core_ext/string'
require 'defined_methods'

module MethodMeter
  mattr_accessor :events, :subscribers, :data, :exceptions

  class << self
    def observe(object, excepted_methods=[])
      init excepted_methods

      DefinedMethods.in(object).each do |group|
        group[:object].module_eval do
          group[:methods].each do |method|
            method_with_profiling, method_without_profiling, event_name = MethodMeter.profiling_method_names(method, group)

            next unless MethodMeter.instrument_method?(method, event_name)

            MethodMeter.events << event_name

            define_method(method_with_profiling) do |*args, &block|
              ActiveSupport::Notifications.instrument(event_name, args) do
                send(method_without_profiling, *args, &block)
              end
            end

            alias_method method_without_profiling, method
            alias_method method, method_with_profiling

            private method_with_profiling if group[:private]
            protected method_with_profiling if group[:protected]
          end
        end
      end
    end

    def measure!(key)
      self.data[key] = {}

      self.events.each do |event|
        self.subscribers << ActiveSupport::Notifications.subscribe(event) do |_, started_at, finished_at, _, _|
          self.data[key][event] = [] unless self.data[key].has_key?(event)
          self.data[key][event] << (finished_at - started_at)
        end
      end

      yield

      self.subscribers.each do |subscriber|
        ActiveSupport::Notifications.unsubscribe(subscriber)
      end
    end

    def measurement
      @measurement ||= begin
        self.data.collect do |key, measurement_records|
          _measurement = measurement_records.collect do |method_name, records|
            total_calls   = records.size
            total_runtime = records.reduce(:+) * 1000
            average       = total_runtime / total_calls

            {
              method: method_name,
              min: records.min * 1000,
              max: records.max * 1000,
              average: average,
              total_runtime: total_runtime,
              total_calls: total_calls,
            }
          end

          { key => _measurement }
        end
      end
    end

    def profiling_method_names(method, group)
      method_with_profiling     = method.to_s + '_with_profiling'
      method_without_profiling  = method.to_s + '_without_profiling'
      event_name                = DefinedMethods.fqmn(group, method)
      [method_with_profiling, method_without_profiling, event_name]
    end

    def instrument_method?(method, event_name)
      !exceptions.include?(method) && !events.include?(event_name) && (event_name =~ /_profiling/).nil?
    end

    def init(excepted_methods)
      self.events =       [] if self.events.nil?
      self.exceptions =   [] if self.exceptions.nil?
      self.exceptions |=  excepted_methods
      self.subscribers  = []
      self.data         = {} if self.data.blank?
    end
  end
end
