require "logger"

class CrystalApi::CrystalLogger < Moonshine::Middleware::Base
  def initialize
    @logger = Logger.new(STDOUT)
    @logger.level = Logger::DEBUG
    @logger.formatter = Logger::Formatter.new do |severity, datetime, progname, message, io|
      io << severity[0] << ", [" << datetime.to_s("%H:%M:%S.%L") << "] "
      io << severity.rjust(5) << ": " << message
    end

    @enabled = true
  end

  def process_request(req)
    @t = Time.now
  end

  def process_response(req, res)
    ts = Time.now - @t as Time
    @logger.debug("#{req.method}  #{req.path} in #{ts.to_f * 1000_000} us")
  end
end
