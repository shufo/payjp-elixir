defmodule Payjp.Customers do
  @moduledoc """
  Main API for working with Customers at Payjp. Through this API you can:

  - create customers
  - get a customer
  - update customer
  - delete single customer
  - delete all customer
  - get customers list
  - get all customers
  - list subscriptions for the customer
  - get a subscription for the customer

  Supports Connect workflow by allowing to pass in any API key explicitely (vs using the one from env/config).


  (API ref: https://pay.jp/docs/api/#customer-顧客
  """

  @endpoint "customers"

  @doc """
  Creates a Customer with the given parameters - all of which are optional.

  ## Example

  ```
    new_customer = [
      email: "test@test.com",
      description: "An Test Account",
      metadata:[
        app_order_id: "ABC123"
        app_state_x: "xyz"
      ],
      card: [
        number: "4111111111111111",
        exp_month: 01,
        exp_year: 2018,
        cvc: 123,
        name: "Joe Test User"
      ]
    ]
    {:ok, res} = Payjp.Customers.create new_customer
  ```

  """
  def create(params) do
    create params, Payjp.config_or_env_key
  end

  @doc """
  Creates a Customer with the given parameters - all of which are optional.
  Using a given payjp key to apply against the account associated.

  ## Example
  ```
  {:ok, res} = Payjp.Customers.create new_customer, key
  ```
  """
  def create(params, key) do
    Payjp.make_request_with_key(:post, @endpoint, key, params)
    |> Payjp.Util.handle_payjp_response
  end


  @doc """
  Retrieves a given Customer with the specified ID. Returns 404 if not found.
  ## Example

  ```
    {:ok, cust} = Payjp.Customers.get "customer_id"
  ```

  """
  def get(id) do
    get id, Payjp.config_or_env_key
  end

  @doc """
  Retrieves a given Customer with the specified ID. Returns 404 if not found.
  Using a given payjp key to apply against the account associated.
  ## Example

  ```
  {:ok, cust} = Payjp.Customers.get "customer_id", key
  ```
  """
  def get(id, key) do
    Payjp.make_request_with_key(:get, "#{@endpoint}/#{id}", key)
    |> Payjp.Util.handle_payjp_response
  end


  @doc """
  Updates a Customer with the given parameters - all of which are optional.

  ## Example

  ```
    new_fields = [
      email: "new_email@test.com",
      description: "New description",
    ]
    {:ok, res} = Payjp.Customers.update(customer_id, new_fields)
  ```

  """
  def update(customer_id, params) do
    update(customer_id, params, Payjp.config_or_env_key)
  end

  @doc """
  Updates a Customer with the given parameters - all of which are optional.
  Using a given payjp key to apply against the account associated.

  ## Example
  ```
  {:ok, res} = Payjp.Customers.update(customer_id, new_fields, key)
  ```
  """
  def update(customer_id, params, key) do
    Payjp.make_request_with_key(:post, "#{@endpoint}/#{customer_id}", key, params)
    |> Payjp.Util.handle_payjp_response
  end



  @doc """
  Returns a list of Customers with a default limit of 10 which you can override with `list/1`

  ## Example

  ```
    {:ok, customers} = Payjp.Customers.list
    {:ok, customers} = Payjp.Customers.list(since: 1487473464, limit: 20)
  ```
  """
  def list(opts \\ []) do
    list Payjp.config_or_env_key, opts
  end

  @doc """
  Returns a list of Customers with a default limit of 10 which you can override with `list/1`
  Using a given payjp key to apply against the account associated.

  ## Example

  ```
  {:ok, customers} = Payjp.Customers.list(key, since: 1487473464, limit: 20)
  ```
  """
  def list(key, opts) do
    Payjp.Util.list @endpoint, key, opts
  end

  @doc """
  Deletes a Customer with the specified ID

  ## Example

  ```
  {:ok, resp} =  Payjp.Customers.delete "customer_id"
  ```
  """
  def delete(id) do
    delete id, Payjp.config_or_env_key
  end

  @doc """
  Deletes a Customer with the specified ID
  Using a given payjp key to apply against the account associated.

  ## Example

  ```
  {:ok, resp} = Payjp.Customers.delete "customer_id", key
  ```
  """
  def delete(id, key) do
    Payjp.make_request_with_key(:delete, "#{@endpoint}/#{id}", key)
    |> Payjp.Util.handle_payjp_response
  end

  @doc """
  Deletes all Customers

  ## Example

  ```
  Payjp.Customers.delete_all
  ```
  """
  def delete_all do
    case all() do
      {:ok, customers} ->
        Enum.each customers, fn c -> delete(c["id"]) end
      {:error, err} -> raise err
    end
  end

  @doc """
  Deletes all Customers
  Using a given payjp key to apply against the account associated.

  ## Example

  ```
  Payjp.Customers.delete_all key
  ```
  """
  def delete_all key do
    case all() do
      {:ok, customers} ->
        Enum.each customers, fn c -> delete(c["id"], key) end
      {:error, err} -> raise err
    end
  end

  @max_fetch_size 100
  @doc """
  List all customers.

  ##Example

  ```
  {:ok, customers} = Payjp.Customers.all
  ```

  """
  def all( accum \\ [], opts \\ [limit: @max_fetch_size]) do
    all Payjp.config_or_env_key, accum, opts
  end

  @doc """
  List all customers.
  Using a given payjp key to apply against the account associated.

  ##Example

  ```
  {:ok, customers} = Payjp.Customers.all key, accum, since
  ```
  """
  def all(key, accum, opts) do
    case Payjp.Util.list_raw("#{@endpoint}", key, opts) do
      {:ok, resp}  ->
        case resp[:has_more] do
          true ->
            last_sub = List.last( resp[:data] )
            all( key, resp[:data] ++ accum, until: last_sub["created"], limit: @max_fetch_size)
          false ->
            result = resp[:data] ++ accum
            {:ok, result}
        end
      {:error, err} -> raise err
    end
  end

  @doc """
  Returns a subscription; customer_id and subscription_id are required.

  ## Example

  ```
  {:ok, sub} = Payjp.Subscriptions.subscription "customer_id", "subscription_id"
  ```

  """
  def subscription(customer_id, sub_id) do
    subscription customer_id, sub_id, Payjp.config_or_env_key
  end

  @doc """
  Returns a subscription using given api key; customer_id and subscription_id are required.

  ## Example

  ```
  {:ok, sub} = Payjp.Subscriptions.subscription "customer_id", "subscription_id", key
  ```

  """
  def subscription(customer_id, sub_id, key) do
    Payjp.make_request_with_key(:get, "#{@endpoint}/#{customer_id}/subscriptions/#{sub_id}", key)
    |> Payjp.Util.handle_payjp_response
  end


  @doc """
  Returns subscription list for the specified customer; customer_id is required.

  ## Example

  ```
  {:ok, sub} = Payjp.Subscriptions.subscriptions "customer_id"
  ```

  """
  def subscriptions( customer_id, accum \\ [], opts \\ []) do
    subscriptions customer_id, accum, Payjp.config_or_env_key, opts
  end

  @doc """
  Returns subscription list for the specified customer with given api key; customer_id is required.

  ## Example

  ```
  {:ok, sub} = Payjp.Subscriptions.subscriptions "customer_id" key, []
  ```

  """
  def subscriptions(customer_id, accum, key, opts) do
    case Payjp.Util.list_raw("#{@endpoint}/#{customer_id}/subscriptions", key, opts) do
      {:ok, resp}  ->
        case resp[:has_more] do
          true ->
            last_sub = List.last( resp[:data] )
            subscriptions(customer_id, resp[:data] ++ accum, key, since: last_sub["created"])
          false ->
            result = resp[:data] ++ accum
            {:ok, result}
        end
    end
  end
end
