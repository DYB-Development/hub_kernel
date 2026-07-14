require "test_helper"

class ConfigureTest < ActiveSupport::TestCase
  test "an adapter bound in configure is returned by resolve" do
    adapter = Object.new
    HubKernel.configure { |c| c.bind(:context, adapter) }

    assert_same adapter, HubKernel.resolve(:context)
  end
end
