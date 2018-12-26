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

  def show_verbose_message(message)
    notify(:show_verbose_message, message)
  end

  def with_status_message(message, &blk)
    notify(:show_status_message, message)
    status = :success
    yield
  rescue
    status = :failure
    raise
  ensure
    notify(:show_status_message, message, status)
  end

  def success_message(message)
    notify(:show_status_message, message, :success)
  end

  def warning_message(message)
    notify(:show_status_message, message, :warning)
  end

  def failure_message(message)
    notify(:show_status_message, message, :failure)
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
