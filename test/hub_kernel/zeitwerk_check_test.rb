require "test_helper"

class HubKernel::ZeitwerkCheckTest < ActiveSupport::TestCase
  test "the host's Zeitwerk check passes with hub folders present" do
    output = Dir.chdir(Rails.root) { `bin/rails zeitwerk:check 2>&1` }

    assert_match "All is good!", output
  end
end
