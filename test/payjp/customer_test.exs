defmodule Payjp.CustomerTest do
  use ExUnit.Case
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  @moduletag :customer

  setup_all do
    use_cassette "customer_test/setup", match_requests_on: [:query, :request_body] do
      Payjp.Customers.delete_all
      customer2 = Helper.create_test_customer "customer_test1@example.com"

      new_customer = [
        email: "test@test.com",
        description: "An Elixir Test Account",
        metadata: [
          app_order_id: "ABC123",
          app_attr1: "xyz"
        ],
        card: [
          number: "4242424242424242",
          exp_month: 01,
          exp_year: 2018,
          cvc: 123,
          name: "Joe Test User"
        ]
      ]
      case Payjp.Customers.create new_customer do
        {:ok, customer} ->
        on_exit fn ->
          use_cassette "customer_test/teardown", match_requests_on: [:query, :request_body] do
            Payjp.Customers.delete customer.id
          end
        end
        {:ok, [customer: customer, customer2: customer2]}

        {:error, err} -> flunk err
      end
    end
  end

  @tag disabled: false
  test "Metadata works", %{customer: customer, customer2: _}  do
    assert customer.metadata["app_order_id"] == "ABC123"
    assert customer.metadata["app_attr1"] == "xyz"
  end

  @tag disabled: false
  test "Count works", %{customer: _, customer2: _}  do
    use_cassette "customer_test/count", match_requests_on: [:query, :request_body] do
      case Payjp.Customers.all do
        {:ok, customers} -> assert length(customers) == 2
        {:error, err} -> flunk err
      end
    end
  end

  @tag disabled: false
  test "Count w/key works", %{customer: _, customer2: _}  do
    use_cassette "customer_test/count_with_key", match_requests_on: [:query, :request_body] do
      case Payjp.Customers.all Payjp.config_or_env_key, [], [limit: 100] do
        {:ok, customers} -> assert length(customers) == 2
        {:error, err} -> flunk err
      end
    end
  end

  @tag disabled: false
  test "Update w/key works", %{customer: customer} do
    use_cassette "customer_test/update_with_key", match_requests_on: [:query, :request_body] do
      new_params = [description: "new description"]
      case Payjp.Customers.update(customer.id, new_params, Payjp.config_or_env_key) do
        {:ok, res} -> assert res.description == "new description"
        {:error, err} -> flunk err
      end
    end
  end

  @tag disabled: false
  test "Update works", %{customer: customer} do
    use_cassette "customer_test/update", match_requests_on: [:query, :request_body] do
      new_params = [description: "new description"]
      case Payjp.Customers.update(customer.id, new_params) do
        {:ok, res} -> assert res.description == "new description"
        {:error, err} -> flunk err
      end
    end
  end

  @tag disabled: false
  test "List works", %{customer: _, customer2: _}  do
    use_cassette "customer_test/list", match_requests_on: [:query, :request_body] do
      case Payjp.Customers.list do
        {:ok, res} ->
          assert length(res[:data]) == 2
          {:error, err} -> flunk err
      end
    end
  end

  @tag disabled: false
  test "List w/key works", %{customer: _, customer2: _}  do
    use_cassette "customer_test/list_with_key", match_requests_on: [:query, :request_body] do
      case Payjp.Customers.list Payjp.config_or_env_key, [] do
        {:ok, res} ->
          assert length(res[:data]) == 2
          {:error, err} -> flunk err
      end
    end
  end

  @tag disabled: false
  test "Retrieve all works", %{customer: _, customer2: _} do
    use_cassette "customer_test/all", match_requests_on: [:query, :request_body] do
      case Payjp.Customers.all do
        {:ok, custs} ->
          assert length(custs) > 0
          {:error, err} -> flunk err
      end
    end
  end

  @tag disabled: false
  test "Retrieve w/key all works", %{customer: _, customer2: _} do
    use_cassette "customer_test/all_with_key", match_requests_on: [:query, :request_body] do
      case Payjp.Customers.all Payjp.config_or_env_key, [], [limit: 100] do
        {:ok, custs} ->
          assert length(custs) > 0
          {:error, err} -> flunk err
      end
    end
  end

  @tag disabled: false
  test "Create works", %{customer: customer, customer2: _} do
    assert customer.id
  end

  @tag disabled: false
  test "Retrieve single works", %{customer: customer, customer2: _} do
    use_cassette "customer_test/get", match_requests_on: [:query, :request_body] do
      case Payjp.Customers.get customer.id do
        {:ok, found} -> assert found.id == customer.id
        {:error, err} -> flunk err
      end
    end
  end

  @tag disabled: false
  test "Delete works", %{customer: customer, customer2: _} do
    use_cassette "customer_test/delete", match_requests_on: [:query, :request_body] do
      case Payjp.Customers.delete customer.id do
        {:ok, res} -> assert res.deleted
        {:error, err} -> flunk err
      end
    end
  end

  @tag disabled: false
  test "Delete w/key works", %{customer: _, customer2: customer2 } do
    use_cassette "customer_test/delete_with_key", match_requests_on: [:query, :request_body] do
      case Payjp.Customers.delete customer2.id, Payjp.config_or_env_key do
        {:ok, res} -> assert res.deleted
        {:error, err} -> flunk err
      end
    end
  end

  @tag disabled: false
  test "Delete all works", %{customer: _, customer2: _} do
    use_cassette "customer_test/delete_all", match_requests_on: [:query, :request_body] do
      Payjp.Customers.delete_all

      use_cassette "customer_test/delete_all_count", match_requests_on: [:query, :request_body] do
        case Payjp.Customers.all do
          {:ok, customers} -> assert length(customers) == 0
          {:error, err} -> flunk err
        end
      end
    end
  end

  @tag disabled: false
  test "Delete all w/key works", %{customer: _, customer2: _} do
    use_cassette "customer_test/delete_all_with_key", match_requests_on: [:query, :request_body] do
      Payjp.Customers.delete_all Payjp.config_or_env_key

      use_cassette "customer_test/delete_all_with_key_count", match_requests_on: [:query, :request_body] do
        case Payjp.Customers.all do
          {:ok, customers} -> assert length(customers) == 0
          {:error, err} -> flunk err
        end
      end
    end
  end
end
