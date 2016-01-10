require "logger"

class CrystalApi::CrystalLogger < Moonshine::Middleware
  def initialize
    @logger = Logger.new(STDOUT)
    @logger.level = Logger::DEBUG
    @logger.formatter = Logger::Formatter.new do |severity, datetime, progname, message, io|
      io << severity[0] << ", [" << datetime.to_s("%H:%M:%S.%L") << "] "
      io << severity.rjust(5) << ": " << message
    end

    @enabled = true

    @t = Time.now
  end

  def process_request(req)
    @t = Time.now
    nil
  end

  def process_response(req, res)
    ts = (Time.now - (@t as Time)).to_f * 1000_000
    res.set_header("X-time-req", ts.to_s)

    db_s = ""
    if res.headers.has_key?("X-time-db")
      db_s += " (#{res.headers["X-time-db"]} db us)"
    end

    @logger.debug("#{req.method}  #{req.path} in #{ts} us#{db_s}")
  end
end
