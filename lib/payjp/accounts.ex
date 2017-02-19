defmodule Payjp.Accounts do
  @moduledoc """
  Functions for working with accounts at Payjp. Through this API you can:

    * get an account,

  Payjp API reference: https://pay.jp/docs/api/#account-アカウント
  """

  @endpoint "accounts"

  @doc """
  Get a account.

  Gets a account.

  Returns a `{:ok, account}` tuple.

  ## Examples

      {:ok, account} = Payjp.Charges.get("charge_id")

  """
  def get do
    get Payjp.config_or_env_key
  end

  @doc """
  Get a account. Accepts Payjp API key.

  Gets a account.

  Returns a `{:ok, account}` tuple.

  ## Examples

      {:ok, charge} = Payjp.Charges.get("charge_id", "my_key")

  """
  def get(key) do
    Payjp.make_request_with_key(:get, "#{@endpoint}", key)
    |> Payjp.Util.handle_payjp_response
  end
end
