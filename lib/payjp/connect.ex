defmodule Payjp.Connect do
  require Map

  @moduledoc """
  Helper module for Connect related features at Payjp.
  Through this API you can:
  - retrieve the oauth access token or the full response, using the code received from the oauth flow return

  (reference https://payjp.com/docs/connect/standalone-accounts)
  """

  def base_url do
    "https://api.pay.jp/v1"
  end
end
