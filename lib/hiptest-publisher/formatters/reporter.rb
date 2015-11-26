

class Reporter
  def initialize(listeners = nil)
    @listeners = listeners || []
  end

  def add_listener(listener)
    @listeners << listener
  end

  def dump_error(error, message = nil)
    notify(:dump_error, error, message)
  end

  def show_options(options, message = nil)
    notify(:show_options, options, message)
  end

  def notify(message, *args)
    @listeners.each do |listener|
      listener.send(message, *args)
    end
    nil
  end
end

class NullReporter
  def method_missing(*args)
  end
end
