defmodule Payjp.Subscriptions do
  @moduledoc """
  Main API for working with Subscriptions at Payjp. Through this API you can:
  - create
  - change
  - retrieve
  - cancel
  - cancel_all
  - list all

  Supports Connect workflow by allowing to pass in any API key explicitely (vs using the one from env/config).

  (API ref https://pay.jp/docs/api/#subscription-定期課金)
  """
  @endpoint "subscriptions"

  @doc """
  Starts a subscription for the specified customer.

  ## Example

  ```
    new_sub = [
      plan: plan_id,
      metadata: [
      ...
      ]
    ]
    {:ok, sub} = Payjp.Subscriptions.create customer_id, new_sub
  ```
  """
  def create( customer_id, opts ) do
    create customer_id, opts, Payjp.config_or_env_key
  end

  @doc """
  Starts a subscription for the specified customer using given api key.

  ## Example

  ```
  new_sub = [
    plan: plan_id,
    metadata: [
    ...
    ]
  ]
  {:ok, sub} = Payjp.Subscriptions.create customer_id, opts, key
  ```
  """
  def create(customer_id, opts, key) do

    opts = Keyword.put_new opts, :customer, customer_id

    Payjp.make_request_with_key(:post, "#{@endpoint}", key, opts)
    |> Payjp.Util.handle_payjp_response
  end


  @doc """
  Returns a subscription; subscription_id is required.

  ## Example

  ```
    {:ok, customer} = Payjp.Subscriptions.get "subscription_id"
  ```
  """
  def get(sub_id) do
    get sub_id, Payjp.config_or_env_key
  end

  @doc """
  Returns a subscription using given api key; subscription_id is required.

  ## Example

  ```
  {:ok, sub} = Payjp.Subscriptions.get "subscription_id", key


  """
  def get(sub_id, key) do
    Payjp.make_request_with_key(:get, "#{@endpoint}/#{sub_id}", key)
    |> Payjp.Util.handle_payjp_response
  end

  @doc """
  Changes a customer's subscription (plan, description, etc - see Payjp API for acceptable options).
  Subscription ID is required for this.

  ## Example
  ```
  Payjp.Subscriptions.change "subscription_id", "plan_id"
  ```
  """
  def change(sub_id, plan_id) do
    change sub_id, plan_id, Payjp.config_or_env_key
  end

  @doc """
  Changes a customer's subscription (plan, description, etc - see Payjp API for acceptable options).
  Customer ID and Subscription ID are required for this.
  Using a given payjp key to apply against the account associated.

  ## Example

  ```
  Payjp.Customers.change_subscription "subscription_id", [plan: "plan_id"], key
  ```
  """
  def change(sub_id, plan_id, key) when is_binary(plan_id) do
    change(sub_id, [plan: plan_id], key)
  end

  @doc """
  Changes a customer's subscription using given api key(plan, description, etc - see Payjp API for acceptable options).
  Customer ID, Subscription ID, opts and api key are required for this.

  ## Example
  ```
  Payjp.Subscriptions.change "subscription_id", [plan: "plan_id"], key
  ```
  """
  def change(sub_id, opts, key) when is_binary(key) do
    Payjp.make_request_with_key(:post, "#{@endpoint}/#{sub_id}", key, opts)
    |> Payjp.Util.handle_payjp_response
  end

  @doc """
  Cancels a subscription

  ## Example

  ```
    Payjp.Subscriptions.cancel "subscription_id"
  ```
  """
  def cancel(sub_id, opts \\ []) do
    cancel sub_id, Payjp.config_or_env_key, opts
  end

  @doc """
  Cancels a subscription with given api key.

  ## Example

  ```
  Payjp.Subscriptions.cancel "subscription_id", key, []
  ```
  """
  def cancel(sub_id, key, opts) when is_binary(key) do
    Payjp.make_request_with_key(:post, "#{@endpoint}/#{sub_id}/cancel", key, opts)
    |> Payjp.Util.handle_payjp_response
  end

  @doc """
  Pauses a subscription

  ## Example

  ```
    Payjp.Subscriptions.pause "subscription_id"
  ```
  """
  def pause(sub_id, opts \\ []) do
    pause sub_id, Payjp.config_or_env_key, opts
  end

  @doc """
  Pauses a subscription with given api key.

  ## Example

  ```
  Payjp.Subscriptions.pause "subscription_id", key, []
  ```
  """
  def pause(sub_id, key, opts) when is_binary(key) do
    Payjp.make_request_with_key(:post, "#{@endpoint}/#{sub_id}/pause", key, opts)
    |> Payjp.Util.handle_payjp_response
  end

  @doc """
  Resumes a subscription

  ## Example

  ```
    Payjp.Subscriptions.resume "subscription_id"
  ```
  """
  def resume(sub_id, opts \\ []) do
    resume sub_id, Payjp.config_or_env_key, opts
  end

  @doc """
  Resumes a subscription with given api key.

  ## Example

  ```
  Payjp.Subscriptions.resume "subscription_id", key, []
  ```
  """
  def resume(sub_id, key, opts) when is_binary(key) do
    Payjp.make_request_with_key(:post, "#{@endpoint}/#{sub_id}/resume", key, opts)
    |> Payjp.Util.handle_payjp_response
  end

  @doc """
  Deletes a subscription

  ## Example

  ```
    Payjp.Subscriptions.delete "subscription_id"
  ```
  """
  def delete(sub_id, opts \\ []) do
    delete sub_id, Payjp.config_or_env_key, opts
  end

  @doc """
  Deletes a subscription with given api key.

  ## Example

  ```
  Payjp.Subscriptions.delete "subscription_id", key, []
  ```
  """
  def delete(sub_id, key, opts) when is_binary(key) do
    Payjp.make_request_with_key(:delete, "#{@endpoint}/#{sub_id}", key, opts)
    |> Payjp.Util.handle_payjp_response
  end

  @doc """
  Cancel all subscriptions for account.

  #Example
  ```
  Payjp.Subscriptions.cancel_all customer_id
  ```
  """
  def cancel_all(customer_id, opts) do
    cancel_all customer_id, opts, Payjp.config_or_env_key
  end

  @doc """
  Cancel all subscriptions for account using given api key.

  #Example
  ```
  Payjp.Subscriptions.cancel_all customer_id, key
  ```
  """
  def cancel_all(customer_id, opts, key) do
    case Payjp.Customers.subscriptions(customer_id) do
      {:ok, subs} ->
        subs
        |> Enum.reject(&(&1["status"] == "canceled"))
        |> Enum.each(&cancel(&1["id"], key, []))
      {:error, err} -> raise err
    end
  end

  @doc """
  Returns a list of Subscriptions with a default limit of 10 which you can override with `list/1`

  ## Example

  ```
    {:ok, subscriptions} = Payjp.Subscriptions.list(limit: 20)
  ```
  """
  def list(opts \\ []) do
    list Payjp.config_or_env_key, opts
  end

  @doc """
  Returns a list of Subscriptions with a default limit of 10 which you can override with `list/1`
  Using a given payjp key to apply against the account associated.

  ## Example

  ```
  {:ok, subscriptions} = Payjp.Subscriptions.list(key, limit: 20)
  ```
  """
  def list(key, opts) do
    Payjp.Util.list @endpoint, key, opts
  end

  @max_fetch_size 100
  @doc """
  List all subscriptions.

  ##Example

  ```
  {:ok, subscriptions} = Payjp.Subscriptions.all
  ```

  """
  def all(accum \\ [], opts \\ [limit: @max_fetch_size]) do
    all accum, Payjp.config_or_env_key, opts
  end

  @doc """
  List all subscriptions using given api key.

  ##Example

  ```
  {:ok, subscriptions} = Payjp.Subscriptions.all [], key, []
  ```

  """
  def all(accum, key, opts) do
    case Payjp.Util.list_raw("#{@endpoint}", key, opts) do
      {:ok, resp}  ->
        case resp[:has_more] do
          true ->
            last_sub = List.last( resp[:data] )
            all(resp[:data] ++ accum, key, since: last_sub["created"], limit: @max_fetch_sizep)
          false ->
            result = resp[:data] ++ accum
            {:ok, result}
        end
    end
  end
end
