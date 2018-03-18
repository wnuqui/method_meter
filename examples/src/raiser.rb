module Raiser
  class << self
    def do(number, exponent)
      do_raise number, exponent
    end

    protected

    def do_raise(number, exponent)
      perform_raising number, exponent
    end

    private

    def perform_raising(number, exponent)
      sleep 0.5
      product = number

      1.upto(exponent - 1) do
        product *= number
      end
    end
  end
end