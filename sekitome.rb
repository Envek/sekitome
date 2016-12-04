# frozen_string_literal: true

require 'bundler'
Bundler.require

# The Throttler Rack application
# Will check whether key specified in +username+ query argument exists in Redis
# and if it exists will return message that this username is throttled.
class Sekitome
  attr_reader :redis, :throttle_timeout

  def initialize
    @throttle_timeout = Integer(ENV.fetch('THROTTLE_TIMEOUT', 60)) # 1 minute by default
    @redis = ConnectionPool::Wrapper.new(size: ENV.fetch('MAX_THREADS', 16)) do
      Redis.new(url: ENV.fetch('REDIS_URL')) # Anyway it will use REDIS_URL, but I want it to fail if not provided
    end
  end

  def call(environment)
    username = Rack::Utils.parse_nested_query(environment['QUERY_STRING'])['username']
    return respond('ERROR: No username provided!', code: :bad_request) unless username
    comparable_username = UnicodeUtils.downcase(username)
    throttled = !redis.set(comparable_username, 1, ex: throttle_timeout, nx: true) # set will return false if key exists
    respond(throttled ? "#{username} throttled" : 'OK', code: throttled ? :too_many_requests : :ok)
  end

  # Prepare a Rack response to pass it back
  # @param  message [String]  Human readable message to be returned to end user
  # @param  code    [Integer] Response's HTTP Status Code
  # @return         [Array]   Rack-compliant triplet of HTTP code, headers and body
  def respond(message, code: :ok)
    code = Rack::Utils::SYMBOL_TO_STATUS_CODE[code] || code
    [code, { 'Content-Type' => 'application/json' }, [Oj.dump('result' => message)]]
  end
end
