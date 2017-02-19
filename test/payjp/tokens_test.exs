defmodule Payjp.TokensTest do
  use ExUnit.Case
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  @moduletag :token

  @tags disabled: false
  test "Create credit card token works"  do
    use_cassette "tokens_test/credit_card", match_requests_on: [:query, :request_body] do
      params = [
        card: [
          number: "4242424242424242",
          exp_month: 12,
          exp_year: 2020,
          cvc: "123"
        ]
      ]
      case Payjp.Tokens.create(params) do
        {:ok, res} ->
          #Apex.ap res
          assert res.id
          {:error, err} -> flunk err
      end
    end
  end

  @tags disabled: false
  test "Create credit card token w/key works" do
    use_cassette "tokens_test/credit_card_with_key", match_requests_on: [:query, :request_body] do
      params = [
        card: [
          number: "4242424242424242",
          exp_month: 12,
          exp_year: 2020,
          cvc: "123"
        ]
      ]
      case Payjp.Tokens.create(params, Payjp.config_or_env_key) do
        {:ok, res} ->
          #Apex.ap res
          assert res.id
          {:error, err} -> flunk err
      end
    end
  end

  @tags disabled: false
  test "Get by id works" do
    use_cassette "tokens_test/get", match_requests_on: [:query, :request_body] do
      {:ok, token} = Payjp.Tokens.create [
        card: [
          number: "4242424242424242",
          exp_month: 12,
          exp_year: 2020,
          cvc: "123"
        ]
      ]
      #Apex.ap token
      case Payjp.Tokens.get token.id do
        {:ok, res} ->
          #Apex.ap res
          assert res.id
          {:error, err} -> flunk err
      end
    end
  end

  @tags disabled: false
  test "Get by id w/key works" do
    use_cassette "tokens_test/get_with_key", match_requests_on: [:query, :request_body] do
      {:ok, token} = Payjp.Tokens.create [
        card: [
          number: "4242424242424242",
          exp_month: 12,
          exp_year: 2020,
          cvc: "123"
        ]
      ]
      #Apex.ap token
      case Payjp.Tokens.get token.id, Payjp.config_or_env_key do
        {:ok, res} ->
          #Apex.ap res
          assert res.id
          {:error, err} -> flunk err
      end
    end
  end


  @tags disabled: false
  test "Charge with token works" do
    use_cassette "tokens_test/charge_with_token", match_requests_on: [:query, :request_body] do
      {:ok, token} = Payjp.Tokens.create [
        card: [
          number: "4242424242424242",
          exp_month: 12,
          exp_year: 2020,
          cvc: "123"
        ]
      ]
      #Apex.ap token
      params = [
        card: token.id
      ]
      case Payjp.Charges.create 100, params do
        {:ok, res} ->
          #Apex.ap res
          assert res.id
          assert res.paid == true
          assert res.object == "charge"
        {:error, err} -> flunk err
      end
    end
  end
end
