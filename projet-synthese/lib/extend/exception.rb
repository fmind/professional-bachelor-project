# Extend ruby exception class
class Exception
  # Extend ruby exception to format exception message to log
  def to_log
    "\n\t#{to_s}#{backtrace.join("\n\t")}"
  end
end