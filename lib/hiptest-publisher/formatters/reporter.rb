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

  def show_error(message)
    notify(:show_error, message)
  end

  def show_failure(message)
    notify(:show_failure, message)
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

  def ask(question)
    askable_listener = @listeners.find { |l| l.respond_to?(:ask) }
    return nil if askable_listener.nil?
    return askable_listener.ask(question)
  end
end

class NullReporter
  def with_status_message(message, &blk)
    yield
  end

  def method_missing(*args)
  end
end
