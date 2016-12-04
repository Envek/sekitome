require 'minitest'
require 'minitest/autorun'
require 'rack/test'
require 'rack-minitest/json'
require 'rack-minitest/assertions'
require_relative '../sekitome'

# Tests running application
class IntegrationTest < Minitest::Test
  include Rack::Test::Methods
  include Rack::Minitest::JSON
  include Rack::Minitest::Assertions

  def app
    ENV['THROTTLE_TIMEOUT'] = '1'
    Sekitome.new
  end

  def assert_response(expected, username:)
    get_json "/?username=#{Rack::Utils.escape(username)}"
    assert_equal expected, last_json_response['result']
  end

  def test_basic_throttling
    assert_response('OK', username: 'andrey')
    assert_response('OK', username: 'яромир')
    assert_response('Andrey throttled', username: 'Andrey')
    assert_response('Яромир throttled', username: 'Яромир')
    sleep 1
    assert_response('OK', username: 'Andrey')
    assert_response('OK', username: 'Яромир')
  end
end
