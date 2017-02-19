defmodule Payjp.Charges do
  @moduledoc """
  Functions for working with charges at Payjp. Through this API you can:

    * create a charge,
    * update a charge,
    * get a charge,
    * list charges,
    * refund a charge,
    * partially refund a charge.

  Payjp API reference: https://pay.jp/docs/api/#charge-支払い
  """

  @endpoint "charges"

  @doc """
  Create a charge.

  Creates a charge for a customer or card using amount and params. `params`
  must include a source.

  Returns `{:ok, charge}` tuple.

  ## Examples

  ### Create a charge with card object

      params = [
        card: [
          number: "4242424242424242",
          exp_month: 10,
          exp_year: 2020,
          country: "JP",
          name: "Ducky Test",
          cvc: 123
        ],
        description: "1000 Widgets"
      ]

      {:ok, charge} = Payjp.Charges.create(1000, params)

  ### Create a charge with card token

      params = [
            card: [
                number: "4242424242424242",
                exp_month: 8,
                exp_year: 2016,
                cvc: "314"
            ]
      ]
      {:ok, token} = Payjp.Tokens.create params

      params = [
        card: token.id
      ]

      {:ok, charge} = Payjp.Charges.create(1000, params)

  ### Create a charge with customer ID

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
      {:ok, customer} = Payjp.Customers.create new_customer

      params = [
        customer: customer.id
      ]

      {:ok, charge} = Payjp.Charges.create(1000, params)
  """
  def create(amount, params) do
    create amount, params, Payjp.config_or_env_key
  end

  @doc """
  Create a charge. Accepts Payjp API key.

  Creates a charge for a customer or card using amount and params. `params`
  must include a source.

  Returns `{:ok, charge}` tuple.

  ## Examples

      {:ok, charge} = Payjp.Charges.create(1000, params, key)

  """
  def create(amount, params, key) do
    #default currency
    params = Keyword.put_new params, :currency, "JPY"
    #drop in the amount
    params = Keyword.put_new params, :amount, amount

    Payjp.make_request_with_key(:post, @endpoint, key, params)
    |> Payjp.Util.handle_payjp_response
  end

  @doc """
  Get a list of charges.

  Gets a list of charges.

  Accepts the following parameters:

    * `opts` - a list of params supported by Payjp (optional; defaults to []). Available parameters are:
      `customer`, `since`, `until`, `subscription`, `limit` and `offset`.

  Returns a `{:ok, charges}` tuple, where `charges` is a list of charges.

  ## Examples

      {:ok, charges} = Payjp.Charges.list(limit: 20) # Get a list of charges up to 20 items (default: 10)
      {:ok, charges} = Payjp.Charges.list(customer: "customer_id") # Get a list of charges for customer
      {:ok, charges} = Payjp.Charges.list(subscription: "subscription_id") # Get a list of charges for given subscription id
      {:ok, charges} = Payjp.Charges.list(since: 1487473464) # Get a list of charges created after specified time stamp

  """
  def list(opts \\ []) do
    list(Payjp.config_or_env_key, opts)
  end

  @doc """
  Get a list of charges. Accepts Payjp API key.

  Gets a list of charges.

  Accepts the following parameters:

    * `opts` - a list of params supported by Payjp (optional; defaults to []). Available parameters are:
    `customer`, `since`, `until`, `subscription`, `limit` and `offset`.

  Returns a `{:ok, charges}` tuple, where `charges` is a list of charges.

  ## Examples

      {:ok, charges} = Payjp.charges.list("my_key") # Get a list of up to 10 charges
      {:ok, charges} = Payjp.charges.list("my_key", limit: 20) # Get a list of up to 20 charges

  """
  def list(key, opts) do
    Payjp.make_request_with_key(:get, "#{@endpoint}", key, opts)
    |> Payjp.Util.handle_payjp_response
  end

  @doc """
  Update a charge.

  Updates a charge with changeable information.

  Accepts the following parameters:

    * `params` - a list of params to be updated (optional; defaults to `[]`).
      Available parameters are: `description`, `metadata`, `receipt_email`,
      `fraud_details` and `shipping`.

  Returns a `{:ok, charge}` tuple.

  ## Examples

      params = [
        description: "Changed charge"
      ]

      {:ok, charge} = Payjp.Charges.change("charge_id", params)

  """
  def change(id, params) do
    change id, params, Payjp.config_or_env_key
  end

  @doc """
  Update a charge. Accepts Payjp API key.

  Updates a charge with changeable information.

  Accepts the following parameters:

    * `params` - a list of params to be updated (optional; defaults to `[]`).
      Available parameters are: `description`, `metadata`, `receipt_email`,
      `fraud_details` and `shipping`.

  Returns a `{:ok, charge}` tuple.

  ## Examples

      params = [
        description: "Changed charge"
      ]

      {:ok, charge} = Payjp.Charges.change("charge_id", params, "my_key")

  """
  def change(id, params, key) do
    Payjp.make_request_with_key(:post, "#{@endpoint}/#{id}", key, params)
    |> Payjp.Util.handle_payjp_response
  end

  @doc """
  Capture a charge.

  Captures a charge that is currently pending.

  Note: you can default a charge to be automatically captured by setting `capture: true` in the charge create params.

  Returns a `{:ok, charge}` tuple.

  ## Examples

      {:ok, charge} = Payjp.Charges.capture("charge_id")

  """
  def capture(id) do
    capture id, Payjp.config_or_env_key
  end

  @doc """
  Capture a charge. Accepts Payjp API key.

  Captures a charge that is currently pending.

  Note: you can default a charge to be automatically captured by setting `capture: true` in the charge create params.

  Returns a `{:ok, charge}` tuple.

  ## Examples

      {:ok, charge} = Payjp.Charges.capture("charge_id", "my_key")

  """
  def capture(id, key) do
    Payjp.make_request_with_key(:post, "#{@endpoint}/#{id}/capture", key)
    |> Payjp.Util.handle_payjp_response
  end

  @doc """
  Get a charge.

  Gets a charge.

  Returns a `{:ok, charge}` tuple.

  ## Examples

      {:ok, charge} = Payjp.Charges.get("charge_id")

  """
  def get(id) do
    get id, Payjp.config_or_env_key
  end

  @doc """
  Get a charge. Accepts Payjp API key.

  Gets a charge.

  Returns a `{:ok, charge}` tuple.

  ## Examples

      {:ok, charge} = Payjp.Charges.get("charge_id", "my_key")

  """
  def get(id, key) do
    Payjp.make_request_with_key(:get, "#{@endpoint}/#{id}", key)
    |> Payjp.Util.handle_payjp_response
  end

  @doc """
  Refund a charge.

  Refunds a charge completely.

  Note: use `refund_partial` if you just want to perform a partial refund.

  Returns a `{:ok, charge}` tuple.

  ## Examples

      {:ok, charge} = Payjp.Charges.refund("charge_id")

  """
  def refund(id) do
    refund id, Payjp.config_or_env_key
  end

  @doc """
  Refund a charge. Accepts Payjp API key.

  Refunds a charge completely.

  Note: use `refund_partial` if you just want to perform a partial refund.

  Returns a `{:ok, charge}` tuple.

  ## Examples

      {:ok, charge} = Payjp.Charges.refund("charge_id", "my_key")

  """
  def refund(id, key) do
    Payjp.make_request_with_key(:post, "#{@endpoint}/#{id}/refund", key)
    |> Payjp.Util.handle_payjp_response
  end

  @doc """
  Partially refund a charge.

  Refunds a charge partially.

  Accepts the following parameters:

    * `amount` - amount to be refunded (required).

  Returns a `{:ok, charge}` tuple.

  ## Examples

      {:ok, charge} = Payjp.Charges.refund_partial("charge_id", 500)

  """
  def refund_partial(id, amount) do
    refund_partial id, amount, Payjp.config_or_env_key
  end

  @doc """
  Partially refund a charge. Accepts Payjp API key.

  Refunds a charge partially.

  Accepts the following parameters:

    * `amount` - amount to be refunded (required).

  Returns a `{:ok, charge}` tuple.

  ## Examples

      {:ok, charge} = Payjp.Charges.refund_partial("charge_id", 500, "my_key")

  """
  def refund_partial(id, amount, key) do
    params = [amount: amount]
    Payjp.make_request_with_key(:post, "#{@endpoint}/#{id}/refund", key, params)
    |> Payjp.Util.handle_payjp_response
  end
end
