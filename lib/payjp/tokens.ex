defmodule Payjp.Tokens do
  @moduledoc """
  API for working with Tokens at Payjp. Through this API you can:
  -create
  -retrieve
  tokens for credit card allowing you to use instead of a credit card number in various operations.

  (API ref https://pay.jp/docs/api/#token-トークン)
  """

  @endpoint "tokens"

  @doc """
  Creates a token.
  ##Example
  ```
     # payload for credit card token
      params = [
            card: [
                number: "4242424242424242",
                exp_month: 8,
                exp_year: 2016,
                cvc: "314"
            ]
      ]

     {:ok, token} = Payjp.Tokens.create params
     IO.puts token.id

  ```
  """
  def create(params) do
    create params, Payjp.config_or_env_key
  end

  @doc """
  Creates a token using given api key.
  ##Example
  ```
  ...
  {:ok, token} = Payjp.Tokens.create params, key
  ...
  ```
  """
  def create(params, key) do
    Payjp.make_request_with_key(:post, @endpoint, key, params)
    |> Payjp.Util.handle_payjp_response
  end

  @doc """
  Retrieve a token by its id. Returns 404 if not found.
  ## Example

  ```
  {:ok, token} = Payjp.Tokens.get "token_id"
  ```
  """
  def get(id) do
    get id, Payjp.config_or_env_key
  end

  @doc """
  Retrieve a token by its id using given api key.
  ## Example

  ```
  {:ok, token} = Payjp.Tokens.get "token_id", key
  ```
  """
  def get(id, key) do
    Payjp.make_request_with_key(:get, "#{@endpoint}/#{id}", key)
    |> Payjp.Util.handle_payjp_response
  end
end
