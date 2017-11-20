defmodule Payjp.Plans do
  @moduledoc """
  Basic List, Create, Delete API for Plans

  - create a plan
  - get a plan
  - update a plan
  - delete a single plan
  - delete all plan
  - list plans
  - get all plans

  https://pay.jp/docs/api/#plan-プラン
  """

  @endpoint "plans"

  @doc """
  Creates a Plan. Note that `currency` and `interval` are required parameters, and are defaulted to "JPY" and "month"

  ## Example

  ```
    {:ok, plan} = Payjp.Plans.create [id: "test-plan", name: "Test Plan", amount: 1000, interval: "month"]
  ```
  """
  def create(params) do
    create params, Payjp.config_or_env_key
  end

  @doc """
  Creates a Plan using a given key. Note that `currency` and `interval` are required parameters, and are defaulted to "JPY" and "month"

  ## Example

  ```
  {:ok, plan} = Payjp.Plans.create [id: "test-plan", name: "Test Plan", amount: 1000, interval: "month"], key
  ```
  """
  def create(params, key) do
    #default the currency and interval
    params = Keyword.put_new params, :currency, "JPY"
    params = Keyword.put_new params, :interval, "month"

    Payjp.make_request_with_key(:post, @endpoint, key, params)
    |> Payjp.Util.handle_payjp_response

  end

  @doc """
  Retrieves a given Plan with the specified ID. Returns 404 if not found.
  ## Example

  ```
    {:ok, cust} = Payjp.Plans.get "plan_id"
  ```

  """
  def get(id) do
    get id, Payjp.config_or_env_key
  end

  @doc """
  Retrieves a given Plan with the specified ID. Returns 404 if not found.
  Using a given payjp key to apply against the account associated.
  ## Example

  ```
  {:ok, cust} = Payjp.Plans.get "plan_id", key
  ```
  """
  def get(id, key) do
    Payjp.make_request_with_key(:get, "#{@endpoint}/#{id}", key)
    |> Payjp.Util.handle_payjp_response
  end

  @doc """
  Returns a list of Plans.

  ## Example

  ```
  {:ok, plans} = Payjp.Plans.list
  {:ok, plans} = Payjp.Plans.list(20)
  ```

  """
  def list(limit \\ 10) do
    list Payjp.config_or_env_key, limit
  end

  @doc """
  Returns a list of Plans using the given key.
  """
  def list(key, limit) do
    Payjp.make_request_with_key(:get, "#{@endpoint}?limit=#{limit}", key)
    |> Payjp.Util.handle_payjp_response
  end

  @doc """

  """
  def retrieve(id) do
    retrieve id, Payjp.config_or_env_key
  end

  @doc """
  Returns a single Plan using the given Plan ID.
  """
  def retrieve(id, key) do
    Payjp.make_request_with_key(:get, "#{@endpoint}/#{id}", key)
    |> Payjp.Util.handle_payjp_response
  end

  @doc """
  Deletes a Plan with the specified ID.

  ## Example

  ```
    {:ok, res} = Payjp.Plans.delete "test-plan"
  ```

  """
  def delete(id) do
    delete id, Payjp.config_or_env_key
  end

  @doc """
  Deletes a Plan with the specified ID using the given key.

  ## Example

  ```
  {:ok, res} = Payjp.Plans.delete "test-plan", key
  ```

  """
  def delete(id, key) do
    Payjp.make_request_with_key(:delete, "#{@endpoint}/#{id}", key)
    |> Payjp.Util.handle_payjp_response
  end

  @doc """
  Changes Plan information. See Payjp docs as to what you can change.

  ## Example

  ```
    {:ok, plan} = Payjp.Plans.change("test-plan",[name: "Other Plan"])
  ```
  """
  def change(id, params) do
    change(id, params, Payjp.config_or_env_key)
  end

  def change(id, params, key) do
    Payjp.make_request_with_key(:post, "#{@endpoint}/#{id}", key, params)
    |> Payjp.Util.handle_payjp_response
  end

  @max_fetch_size 100
  @doc """
  List all plans.
  ##Example
  ```
  {:ok, plans} = Payjp.Plans.all
      ```
      """
  def all( accum \\ [], opts \\ [limit: @max_fetch_size]) do
    all Payjp.config_or_env_key, accum, opts
  end

  @max_fetch_size 100
  @doc """
  List all plans w/ given key.
  ##Example
  ```
  {:ok, plans} = Payjp.Plans.all key
  ```
  """
  def all( key, accum, opts) do
      case Payjp.Util.list_raw("#{@endpoint}", key, opts) do
      {:ok, resp}  ->
          case resp[:has_more] do
          true ->
              last_plan = List.last( resp[:data] )
              all( key, resp[:data] ++ accum, until: last_plan["created"], limit: @max_fetch_size)
          false ->
              result = resp[:data] ++ accum
              {:ok, result}
          end
      end
  end

  @doc """
  Deletes all Plans
  ## Example
  ```
  Payjp.Plans.delete_all
  ```
  """
  def delete_all do
    delete_all Payjp.config_or_env_key
  end


  @doc """
  Deletes all Plans w/given key
  ## Example
  ```
  Payjp.Plans.delete_all key
  ```
  """
  def delete_all key do
    case all() do
      {:ok, plans} ->
        Enum.each plans, fn p -> delete(p["id"], key) end
      {:error, err} -> raise err
    end
    {:ok}
  end
end
