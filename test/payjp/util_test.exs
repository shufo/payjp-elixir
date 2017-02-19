defmodule Payjp.UtilTest do
  use ExUnit.Case
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  @moduletag :util

  setup_all do
    use_cassette "util_test/setup", match_requests_on: [:query, :request_body] do
      Payjp.Plans.delete_all
      Helper.create_test_plans

      on_exit fn ->
        use_cassette "util_test/teardown", match_requests_on: [:query, :request_body] do
          Payjp.Plans.delete_all
        end
      end
      :ok
    end
  end

  test "list_raw" do
    use_cassette "util_test/list_raw", match_requests_on: [:query, :request_body] do
      case Payjp.Util.list_raw "plans" do
        {:ok, plans} -> assert plans
        {:error, err} -> flunk err
      end
    end
  end
  test "list_raw w/key" do
    use_cassette "util_test/list_raw_with_key", match_requests_on: [:query, :request_body] do
      case Payjp.Util.list_raw "plans", Payjp.config_or_env_key, [] do
        {:ok, plans} -> assert plans
        {:error, err} -> flunk err
      end
    end
  end

  @tag disabled: false
  test "list works" do
    use_cassette "util_test/list", match_requests_on: [:query, :request_body] do
      case Payjp.Util.list "plans" do
        {:ok, resp} ->
          assert length(resp[:data]) == 2
          {:error, err} -> flunk err
      end
    end
  end

  @tag disabled: false
  test "list w/key works" do
    use_cassette "util_test/list_with_key", match_requests_on: [:query, :request_body] do
      case Payjp.Util.list "plans", Payjp.config_or_env_key, []  do
        {:ok, resp} -> assert length( resp[:data]) == 2
        {:error, err} -> flunk err
      end
    end
  end
end
