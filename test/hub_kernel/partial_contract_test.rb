require "test_helper"

module HubKernel
  class PartialContractTest < ActionView::TestCase
    test "a gem's partial draws no heading of its own" do
      render partial: "pretend_gem/name", locals: { person: "a-person", account: "an-account", submit_url: "/somewhere" }

      assert_no_match(/<h1/, rendered)
    end

    test "a gem's partial submits to the address it was given" do
      render partial: "pretend_gem/name", locals: { person: "a-person", account: "an-account", submit_url: "/somewhere" }

      assert_match('action="/somewhere"', rendered)
    end
  end
end
