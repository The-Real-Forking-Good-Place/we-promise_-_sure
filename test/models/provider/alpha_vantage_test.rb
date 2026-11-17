require "test_helper"

class Provider::AlphaVantageTest < ActiveSupport::TestCase
  test "client sets explicit open and read timeouts" do
    provider = Provider::AlphaVantage.new("test_api_key")
    options = provider.send(:client).options

    assert_equal 5, options.open_timeout
    assert_equal 20, options.timeout
  end

  test "a timed-out request returns a failed response with the provider's Error" do
    provider = Provider::AlphaVantage.new("test_api_key")
    provider.stubs(:throttle_request)
    Faraday::Retry::Middleware.any_instance.stubs(:sleep)
    stub_request(:get, %r{\Ahttps://www\.alphavantage\.co/}).to_timeout

    response = provider.search_securities("TEST")

    assert_not response.success?
    assert_instance_of Provider::AlphaVantage::Error, response.error
  end
end
