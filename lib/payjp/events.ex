defmodule Payjp.Events do
  @moduledoc """
  Main API for working with Events at Payjp. Through this API you can:
  -list events
  -retrieve event from id

  https://pay.jp/docs/api/#event-イベント
  """

  @endpoint "events"


  @doc """
  Retrieves a given Event with the specified ID. Returns 404 if not found.
  ## Example

  ```
  Payjp.Events.get "event_id"
  ```

  """
  def get(id) do
    get Payjp.config_or_env_key, id
  end

  @doc """
  Retrieves a given Event with the specified ID using that key(account).
  Returns 404 if not found.
  ## Example

  ```
  {:ok, event} = Payjp.Events.get  key, "event_id"
  ```

  """
  def get(key, id) do
    Payjp.make_request_with_key(:get, "#{@endpoint}/#{id}", key)
        |> Payjp.Util.handle_payjp_full_response
  end

  @doc """
  Returns a list of events

  ## Example

  ```
  {:ok, events} = Payjp.Events.list limit: 20
  {:ok, events} = Payjp.Events.list type: "charge.updated"
  {:ok, events} = Payjp.Events.list type: "charge.updated", limit: 20
  {:ok, events} = Payjp.Events.list since: 1487473464
  {:ok, events} = Payjp.Events.list until: 1487473464
  {:ok, events} = Payjp.Events.list object: "customer"
  ```

  """
  def list(opts \\ []) do
    list Payjp.config_or_env_key, opts
  end

  @doc """
  Returns a list of events using given payjp key

  ## Example

  ## Example

  ```
  {:ok, events} = Payjp.Events.list key, limit: 20
  {:ok, events} = Payjp.Events.list key, type: "charge.updated"
  {:ok, events} = Payjp.Events.list key, type: "charge.updated", limit: 20
  {:ok, events} = Payjp.Events.list key, since: 1487473464
  {:ok, events} = Payjp.Events.list key, until: 1487473464
  {:ok, events} = Payjp.Events.list key, object: "customer"

  """
  def list(key, opts) do
    Payjp.Util.list_raw("#{@endpoint}", key, opts)
  end
end
