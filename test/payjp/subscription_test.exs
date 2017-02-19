defmodule Payjp.SubscriptionTest do
  use ExUnit.Case, async: false
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  @moduletag :subscription

  #these tests are dependent on the execution order
  # ExUnit.configure w/ seed: 0 was set
  setup_all do
    use_cassette "subscription_test/setup", match_requests_on: [:query, :request_body] do
      Payjp.Customers.delete_all
      Helper.create_test_plans
      customer = Helper.create_test_customer "subscription_test1@example.com"
      Helper.create_test_plan "test-cancel-all"
      Helper.create_test_plan "test-dlx"
      Helper.create_test_plan "test-dly"
      Helper.create_test_plan "test-dlz"
      Helper.create_test_plan "test-dla"
      {:ok, sub1} = Payjp.Subscriptions.create customer.id, [plan: "test-std"]
      {:ok, sub2} = Payjp.Subscriptions.create customer.id, [plan: "test-dlx"]
      {:ok, sub3} = Payjp.Subscriptions.create customer.id, [plan: "test-dla"]

      on_exit fn ->
        use_cassette "subscription_test/teardown", match_requests_on: [:query, :request_body] do
          Payjp.Subscriptions.cancel sub1.id
          Payjp.Subscriptions.cancel sub2.id
          Payjp.Customers.delete customer.id
          Payjp.Plans.delete_all
        end
      end

      {:ok, [ customer: customer, sub1: sub1, sub2: sub2, sub3: sub3 ] }
    end
  end

  @tag disabled: false
  test "Retrieving single works", %{customer: customer, sub1: sub1, sub2: _} do
    use_cassette "subscription_test/get", match_requests_on: [:query, :request_body] do
      case Payjp.Subscriptions.get sub1.id do
        {:ok, found} -> assert found.id
        {:error, err} -> flunk err
      end
    end
  end

  @tag disabled: false
  test "Retrieving single w/key works", %{customer: customer, sub1: sub1, sub2: _} do
    use_cassette "subscription_test/get_with_key", match_requests_on: [:query, :request_body] do
      case Payjp.Subscriptions.get sub1.id, Payjp.config_or_env_key do
        {:ok, found} -> assert found.id
        {:error, err} -> flunk err
      end
    end
  end


  @tag disabled: false
  test "Retrieve all works", %{customer: customer} do
    use_cassette "subscription_test/all", match_requests_on: [:query, :request_body] do
      case Payjp.Customers.subscriptions customer.id do
        {:ok, subs} -> assert Enum.count(subs) == 3
        {:error, err} -> flunk err
      end
    end
  end

  @tag disabled: false
  test "Retrieve all w/key works", %{customer: customer} do
    use_cassette "subscription_test/all", match_requests_on: [:query, :request_body] do
      case Payjp.Customers.subscriptions customer.id, [], Payjp.config_or_env_key, [] do
        {:ok, subs} -> assert Enum.count(subs) == 3
        {:error, err} -> flunk err
      end
    end
  end

  @tag disabled: false
  test "Create w/opts  works", %{customer: customer, sub1: _, sub2: _} do
    use_cassette "subscription_test/create_with_opts", match_requests_on: [:query, :request_body] do
      Helper.create_test_plan "test-create-a"
      opts = [
        plan: "test-create-a"
      ]
      case Payjp.Subscriptions.create customer.id, opts do
        {:ok, sub} -> assert sub.customer == customer.id
        {:error, err} -> flunk err
      end
    end
  end

  @tag disabled: false
  test "Create w/opts w/key works", %{customer: customer, sub1: _, sub2: _} do
    use_cassette "subscription_test/create_with_key_with_opts", match_requests_on: [:query, :request_body] do
      Helper.create_test_plan "test-create-b"

      opts = [
        plan: "test-create-b"
      ]
      case Payjp.Subscriptions.create customer.id, opts, Payjp.config_or_env_key do
        {:ok, sub} ->
          assert sub.customer == customer.id
          {:error, err} -> flunk err
      end
    end
  end

  @tag disabled: false
  test "Change works", %{customer: customer, sub1: sub1, sub2: _} do
    use_cassette "subscription_test/change", match_requests_on: [:query, :request_body] do
      case Payjp.Subscriptions.change sub1.id, "test-dlz" do
        {:ok, changed} -> assert changed.plan["id"] == "test-dlz"
        {:error, err} -> flunk err
      end
    end
  end

  @tag disabled: false
  test "General change works", %{ customer: customer, sub1: sub1 } do
    use_cassette "subscription_test/general_change", match_requests_on: [:query, :request_body] do
      case Payjp.Subscriptions.change sub1.id, [metadata: ["test": "foo"]] do
        {:ok, changed} -> assert changed.metadata["test"] == "foo"
        {:error, err} -> flunk err
      end
    end
  end

  @tag disabled: false
  test "Change w/key works", %{customer: customer, sub1: _, sub2: sub2} do
    use_cassette "subscription_test/change_with_key", match_requests_on: [:query, :request_body] do
      case Payjp.Subscriptions.change sub2.id, "test-dly", Payjp.config_or_env_key do
        {:ok, changed} -> assert changed.plan["id"] == "test-dly"
        {:error, err} -> flunk err
      end
    end
  end

  @tag disabled: false
  test "Cancel works", %{customer: customer, sub1: sub1, sub2: _} do
    use_cassette "subscription_test/cancel", match_requests_on: [:query, :request_body] do
      case Payjp.Subscriptions.cancel sub1.id do
        {:ok, canceled_sub} -> assert canceled_sub.id
        {:error, err} -> flunk err
      end
    end
  end

  @tag disabled: false
  test "Cancel w/key works", %{customer: customer, sub1: _, sub2: sub2} do
    use_cassette "subscription_test/cancel_with_key", match_requests_on: [:query, :request_body] do
      case Payjp.Subscriptions.cancel sub2.id, Payjp.config_or_env_key, [] do
        {:ok, canceled_sub} -> assert canceled_sub.id
        {:error, err} -> flunk err
      end
    end
  end

  @tag disabled: false
  test "Cancel all works", %{customer: customer,  sub1: _, sub2: _} do
    use_cassette "subscription_test/cancel_all", match_requests_on: [:query, :request_body] do
      Payjp.Subscriptions.cancel_all customer.id, []
      {:ok, subs} = Payjp.Subscriptions.all
      assert length(subs |> Enum.filter(&(&1["status"] == "active"))) == 0
    end
  end

  @tag disabled: false
  test "Cancel all w/key  works", %{customer: customer,  sub1: _, sub2: _} do
    use_cassette "subscription_test/cancel_all_with_key", match_requests_on: [:query, :request_body] do
      Payjp.Subscriptions.create customer.id, [plan: "test-cancel-all"]
      Payjp.Subscriptions.cancel_all customer.id, [],Payjp.config_or_env_key
      {:ok, subs} = Payjp.Subscriptions.all
      assert length(subs |> Enum.filter(&(&1["status"] == "active"))) == 0
    end
  end
end
