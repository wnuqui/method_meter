require 'method_meter/version'

require 'active_support'
require 'defined_methods'

module MethodMeter
  mattr_accessor :metered_methods, :subscribers, :data, :exceptions

  class << self
    def observe(object, excepted_methods=[])
      init excepted_methods

      DefinedMethods.in(object).each do |group|
        group[:object].module_eval do
          group[:methods].each do |method|
            MethodMeter.define_metering_method(group[:object], method, group[:private], group[:protected], group[:singleton])
          end
        end
      end
    end

    def measure!(key)
      data[key] = {}

      metered_methods.each do |metered_method|
        subscribers << ActiveSupport::Notifications.subscribe(metered_method) do |_, started_at, finished_at, _, _|
          data[key][metered_method] = [] unless data[key].has_key?(metered_method)
          data[key][metered_method] << (finished_at - started_at)
        end
      end

      yield

      subscribers.each do |subscriber|
        ActiveSupport::Notifications.unsubscribe(subscriber)
      end
    end

    def measurement
      measurement = {}

      data.each do |key, measurement_records|
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

        measurement[key] = _measurement
      end

      measurement
    end

    def profiling_method_names(method)
      method_with_profiling     = method.to_s + '_with_profiling'
      method_without_profiling  = method.to_s + '_without_profiling'
      [method_with_profiling, method_without_profiling]
    end

    def meter_method?(method_name)
      object_name, method = method_name.split('#')
      object_name, method = method_name.split('.') if method.nil?
      !exceptions.include?(method.to_sym) && !metered_methods.include?(method_name) && (method_name =~ /_profiling/).nil?
    end

    def define_metering_method(object, method, is_private, is_protected, is_singleton)
      object.module_eval do
        method_with_profiling, method_without_profiling = MethodMeter.profiling_method_names(method)
        object_name = is_singleton ? object.to_s.split(':').last.gsub('>', '') : object.to_s
        method_name = DefinedMethods.fqmn(object_name, method, is_singleton)

        return unless MethodMeter.meter_method?(method_name)

        MethodMeter.metered_methods << method_name

        define_method(method_with_profiling) do |*args, &block|
          ActiveSupport::Notifications.instrument(method_name, args) do
            send(method_without_profiling, *args, &block)
          end
        end

        alias_method method_without_profiling, method
        alias_method method, method_with_profiling

        private method_with_profiling if is_private
        protected method_with_profiling if is_protected
      end
    end

    private

    def init(excepted_methods)
      self.metered_methods = [] if metered_methods.nil?
      self.exceptions      = [] if exceptions.nil?
      self.exceptions     |= excepted_methods
      self.subscribers     = []
      self.data            = {} if data.blank?
    end
  end
end
