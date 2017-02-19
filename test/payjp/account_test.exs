defmodule Payjp.AccountTest do
  use ExUnit.Case
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  @moduletag :account

  @tag disabled: false
  test "Retrieve account works" do
    use_cassette "account_test/get", match_requests_on: [:query, :request_body] do
      {:ok, accounts} = Payjp.Accounts.get
      assert map_size(accounts) > 0
    end
  end
end
