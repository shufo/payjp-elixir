defmodule Payjp.ChargeTest do
  use ExUnit.Case
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  @moduletag :charge

  setup_all do
    use_cassette "charge_test/setup", match_requests_on: [:query, :request_body] do
      Payjp.Customers.delete_all
      customer = Helper.create_test_customer "customer_test1@example.com"

      on_exit fn ->
        use_cassette "charge_test/teardown1", match_requests_on: [:query, :request_body] do
          Payjp.Customers.delete customer.id
        end
      end

      params = [
        card: [
          number: "4242424242424242",
          exp_month: 02,
          exp_year: 2020,
          country: "JP",
          name: "Ducky Test",
          cvc: 123
        ],
        description: "1000 Widgets"
      ]

      card_params = [
        number: "4242424242424242",
        exp_month: 02,
        exp_year: 2020,
        country: "JP",
        name: "Ducky Test",
        cvc: 123
      ]

      case Payjp.Cards.create :customer, customer.id, card_params do
        {:ok, card} ->
          on_exit fn ->
            use_cassette "charge_test/teardown2", match_requests_on: [:query, :request_body] do
              Payjp.Cards.delete :customer, customer.id, card.id
            end
          end
          {:ok, [params: params, customer: customer, card: card]}
      end
    end
  end

  test "Create with card works", %{params: params} do
    use_cassette "charge_test/create", match_requests_on: [:query, :request_body] do
      case Payjp.Charges.create(1000,params) do
        {:ok, res} -> assert res.id
        {:error, err} -> flunk err
      end
    end
  end

  test "Create with card, w/key works", %{params: params} do
    use_cassette "charge_test/create_with_key", match_requests_on: [:query, :request_body] do
      case Payjp.Charges.create(1000,params, Payjp.config_or_env_key) do
        {:ok, res} -> assert res.id
        {:error, err} -> flunk err
      end
    end
  end

  test "List works" do
    use_cassette "charge_test/list", match_requests_on: [:query, :request_body] do
      case Payjp.Charges.list() do
        {:ok, charges} -> assert length(charges) > 0
        {:error, err} -> flunk err
      end
    end
  end

  test "List with customer works", context do
    use_cassette "charge_test/list_with_customer", match_requests_on: [:query, :request_body] do
      Payjp.Charges.create(1000, customer: context.customer.id)
      case Payjp.Charges.list(customer: context.customer.id) do
        {:ok, charges} -> assert length(charges) > 0
        {:error, err} -> flunk err
      end
    end
  end

  test "List w/key works" do
    use_cassette "charge_test/list_with_key", match_requests_on: [:query, :request_body] do
      case Payjp.Charges.list Payjp.config_or_env_key, limit: 1 do
        {:ok, charges} -> assert length(charges) > 0
        {:error, err} -> flunk err
      end
    end
  end

  test "Get works" do
    use_cassette "charge_test/get", match_requests_on: [:query, :request_body] do
      {:ok,[first | _]} = Payjp.Charges.list()
      case Payjp.Charges.get(first.id) do
        {:ok, charge} -> assert charge.id == first.id
        {:error, err} -> flunk err
      end
    end
  end

  test "Get w/key works" do
    use_cassette "charge_test/get_with_key", match_requests_on: [:query, :request_body] do
      {:ok,[first | _]} = Payjp.Charges.list Payjp.config_or_env_key, limit: 1
      case Payjp.Charges.get(first.id, Payjp.config_or_env_key) do
        {:ok, charge} -> assert charge.id == first.id
        {:error, err} -> flunk err
      end
    end
  end

  test "Capture works", %{params: params} do
    use_cassette "charge_test/capture", match_requests_on: [:query, :request_body] do
      params = Keyword.put_new params, :capture, false
      {:ok, charge} = Payjp.Charges.create(1000,params)
      case Payjp.Charges.capture(charge.id) do
        {:ok, captured} -> assert captured.id == charge.id
        {:error, err} -> flunk err
      end
    end
  end

  test "Capture w/key works", %{params: params} do
    use_cassette "charge_test/capture_with_key", match_requests_on: [:query, :request_body] do
      params = Keyword.put_new params, :capture, false
      {:ok, charge} = Payjp.Charges.create(1000,params, Payjp.config_or_env_key)
      case Payjp.Charges.capture(charge.id, Payjp.config_or_env_key) do
        {:ok, captured} -> assert captured.id == charge.id
        {:error, err} -> flunk err
      end
    end
  end

  test "Change(Update) works", %{params: params} do
    use_cassette "charge_test/change", match_requests_on: [:query, :request_body] do
      {:ok, charge} = Payjp.Charges.create(1000, params)
      params = [description: "Changed charge"]
      case Payjp.Charges.change(charge.id, params) do
        {:ok, changed} -> assert changed.description == "Changed charge"
        {:error, err} -> flunk err
      end
    end
  end

  test "Change(Update) w/key works", %{params: params} do
    use_cassette "charge_test/change_with_key", match_requests_on: [:query, :request_body] do
      {:ok, charge} = Payjp.Charges.create(2000,params, Payjp.config_or_env_key)
      params = [description: "Changed charge"]
      case Payjp.Charges.change(charge.id, params, Payjp.config_or_env_key) do
        {:ok, changed} -> assert changed.description == "Changed charge"
        {:error, err} -> flunk err
      end
    end
  end

  test "Refund works", %{params: params} do
    use_cassette "charge_test/partial_refund", match_requests_on: [:query, :request_body] do
      {:ok, charge} = Payjp.Charges.create(3000,params)
      case Payjp.Charges.refund_partial(charge.id,500) do
        {:ok, refunded} -> assert refunded.amount_refunded == 500
        {:error, err} -> flunk err
      end
    end
  end

  test "Refund w/key works", %{params: params} do
    use_cassette "charge_test/partial_refund_with_key", match_requests_on: [:query, :request_body] do
      {:ok, charge} = Payjp.Charges.create(5000,params, Payjp.config_or_env_key)
      case Payjp.Charges.refund_partial(charge.id,500, Payjp.config_or_env_key) do
        {:ok, refunded} -> assert refunded.amount_refunded == 500
        {:error, err} -> flunk err
      end
    end
  end
end
