class Arithmeter
  def self.sum(a, b)
    arithmeter = new
    arithmeter.add a, b
  end

  def add(a, b)
    do_add a, b
  end

  private

  def do_add(a, b)
    sleep 1/10.0
    perform_addition a, b
  end

  protected

  def perform_addition(a, b)
    sleep 1/4.0
    a + b
  end
end