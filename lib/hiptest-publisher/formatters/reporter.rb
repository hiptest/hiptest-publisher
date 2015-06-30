

class Reporter
  def initialize
    @listeners = []
  end

  def add_listener(listener)
    @listeners << listener
  end

  def dump_error(error, message = nil)
    @listeners.each do |listener|
      listener.dump_error(error, message)
    end
  end

  def show_options(options)
    @listeners.each do |listener|
      listener.show_options(options)
    end
  end
end

class NullReporter
  def method_missing(*args)
  end
end
