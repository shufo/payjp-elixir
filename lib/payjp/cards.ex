defmodule Payjp.Cards do
  @moduledoc """
  Functions for working with cards at Payjp. Through this API you can:

    * create a card,
    * update a card,
    * get a card,
    * delete a card,
    * delete all cards,
    * list cards,
    * list all cards,

  All requests require `owner_type` and `owner_id` parameters to be specified.

  `owner_type` must be one of the following:

    * `customer`

  `owner_id` must be the ID of the owning object.

  Payjp API reference: https://pay.jp/docs/api/#顧客のカードを作成
  """

  def endpoint_for_entity(entity_type, entity_id) do
    case entity_type do
      :customer -> "customers/#{entity_id}/cards"
    end
  end

  @doc """
  Create a card.

  Creates a card for given owner type, owner ID using params.

  `params` must contain a "card" object. Inside the "card" object, the following parameters are required:

    * number,
    * cvs,
    * exp_month,
    * exp_year.

  Returns a `{:ok, card}` tuple.

  ## Examples

      params = [
        card: [
          number: "4242424242424242",
          cvc: 123,
          exp_month: 12,
          exp_year: 2020,
        ],
        metadata: [
          test_field: "test val"
        ]
      ]

      {:ok, card} = Payjp.Cards.create(:customer, customer_id, params)

  """
  def create(owner_type, owner_id, params) do
    create owner_type, owner_id, params, Payjp.config_or_env_key
  end

  @doc """
  Create a card. Accepts Payjp API key.

  Creates a card for given owner using params.

  `params` must contain a "card" object. Inside the "card" object, the following parameters are required:

    * number,
    * cvs,
    * exp_month,
    * exp_year.

  Returns a `{:ok, card}` tuple.

  ## Examples

      {:ok, card} = Payjp.Cards.create(:customer, customer_id, params, key)

  """
  def create(owner_type, owner_id, params, key) do
    Payjp.make_request_with_key(:post, endpoint_for_entity(owner_type, owner_id), key, params)
    |> Payjp.Util.handle_payjp_response
  end

  @doc """
  Update a card.

  Updates a card for given owner using card ID and params.

    * `owner_type` must be one of the following:

      * `customer`,

    * `owner_id` must be the ID of the owning object.

  Returns a `{:ok, card}` tuple.

  ## Examples

      {:ok, card} = Payjp.Cards.update(:customer, customer_id, card_id, params)

  """
  def update(owner_type, owner_id, id, params) do
    update(owner_type, owner_id, id, params, Payjp.config_or_env_key)
  end

  @doc """
  Update a card. Accepts Payjp API key.

  Updates a card for given owner using card ID and params.

  Returns a `{:ok, card}` tuple.

  ## Examples

      {:ok, card} = Payjp.Cards.update(:customer, customer_id, card_id, params, key)

  """
  def update(owner_type, owner_id, id, params, key) do
    Payjp.make_request_with_key(:post, "#{endpoint_for_entity(owner_type, owner_id)}/#{id}", key, params)
    |> Payjp.Util.handle_payjp_response
  end

  @doc """
  Get a card.

  Gets a card for given owner using card ID.

  Returns a `{:ok, card}` tuple.

  ## Examples

      {:ok, card} = Payjp.Cards.get(:customer, customer_id, card_id)

  """
  def get(owner_type, owner_id, id) do
    get owner_type, owner_id, id, Payjp.config_or_env_key
  end

  @doc """
  Get a card. Accepts Payjp API key.

  Gets a card for given owner using card ID.

  Returns a `{:ok, card}` tuple.

  ## Examples

      {:ok, card} = Payjp.Cards.get(:customer, customer_id, card_id, key)

  """
  def get(owner_type, owner_id, id, key) do
    Payjp.make_request_with_key(:get, "#{endpoint_for_entity(owner_type, owner_id)}/#{id}", key)
    |> Payjp.Util.handle_payjp_response
  end

  @doc """
  Get a list of cards.

  Gets a list of cards for given owner.

  Accepts the following parameters:

    * `limit` - a limit of items to be returned (optional; defaults to 10).
    * `offset` - an offset (optional),
    * `since` - a timestamp for returning subsequent data specified here (optional),
    * `until` - a timestamp for returning the previous data specified here (optional),

  Returns a `{:ok, cards}` tuple, where `cards` is a list of cards.

  ## Examples

      {:ok, cards} = Payjp.Cards.list(:customer, customer_id, offset: 5) # Get a list of up to 10 cards, skipping first 5 cards
      {:ok, cards} = Payjp.Cards.list(:customer, customer_id, offset: 5, limit: 20) # Get a list of up to 20 cards, skipping first 5 cards

  """
  def list(owner_type, owner_id, opts \\ []) do
    list owner_type, owner_id, Payjp.config_or_env_key, opts
  end

  @doc """
  Get a list of cards. Accepts Payjp API key.

  Gets a list of cards for a given owner.

  Accepts the following parameters:

    * `limit` - a limit of items to be returned (optional; defaults to 10).
    * `offset` - an offset (optional),
    * `since` - a timestamp for returning subsequent data specified here (optional),
    * `until` - a timestamp for returning the previous data specified here (optional),

  Returns a `{:ok, cards}` tuple, where `cards` is a list of cards.

  ## Examples

  {:ok, cards} = Payjp.Cards.list(:customer, customer_id, offset: 5) # Get a list of up to 10 cards, skipping first 5 cards
  {:ok, cards} = Payjp.Cards.list(:customer, customer_id, offset: 5, limit: 20) # Get a list of up to 20 cards, skipping first 5 cards

  """
  def list(owner_type, owner_id, key, opts) do
    Payjp.Util.list endpoint_for_entity(owner_type, owner_id), key, opts
  end

  @doc """
  Delete a card.

  Deletes a card for given owner using card ID.

  Returns a `{:ok, card}` tuple.

  ## Examples

      {:ok, deleted_card} = Payjp.Cards.delete("card_id")

  """
  def delete(owner_type, owner_id, id) do
    delete owner_type, owner_id, id, Payjp.config_or_env_key
  end

  @doc """
  Delete a card. Accepts Payjp API key.

  Deletes a card for given owner using card ID.

  Returns a `{:ok, card}` tuple.

  ## Examples

      {:ok, deleted_card} = Payjp.Cards.delete("card_id", key)

  """
  def delete(owner_type, owner_id, id,key) do
    Payjp.make_request_with_key(:delete, "#{endpoint_for_entity(owner_type, owner_id)}/#{id}", key)
    |> Payjp.Util.handle_payjp_response
  end

  @doc """
  Delete all cards.

  Deletes all cards from given owner.

  Returns `:ok` atom.

  ## Examples

      :ok = Payjp.Cards.delete_all(:customer, customer_id)

  """
  def delete_all(owner_type, owner_id) do
    case all(owner_type, owner_id) do
      {:ok, cards} ->
        Enum.each cards, fn c -> delete(owner_type, owner_id, c["id"]) end
      {:error, err} -> raise err
    end
  end

  @doc """
  Delete all cards. Accepts Payjp API key.

  Deletes all cards from given owner.

  Returns `:ok` atom.

  ## Examples

      :ok = Payjp.Cards.delete_all(:customer, customer_id, key)

  """
  def delete_all(owner_type, owner_id, key) do
    case all(owner_type, owner_id) do
      {:ok, customers} ->
        Enum.each customers, fn c -> delete(owner_type, owner_id, c["id"], key) end
      {:error, err} -> raise err
    end
  end

  @max_fetch_size 100
  @doc """
  List all cards.

  Lists all cards for a given owner.

  Accepts the following parameters:

    * `accum` - a list to start accumulating cards to (optional; defaults to `[]`).,
    * `since` - an offset (optional; defaults to `""`).

  Returns `{:ok, cards}` tuple.

  ## Examples

      {:ok, cards} = Payjp.Cards.all(:customer, customer_id, accum, since)

  """
  def all(owner_type, owner_id, accum \\ [], opts \\ [limit: @max_fetch_size]) do
    all owner_type, owner_id, Payjp.config_or_env_key, accum, opts
  end

  @doc """
  List all cards. Accepts Payjp API key.

  Lists all cards for a given owner.

  Accepts the following parameters:

    * `accum` - a list to start accumulating cards to (optional; defaults to `[]`).,
    * `since` - an offset (optional; defaults to `""`).

  Returns `{:ok, cards}` tuple.

  ## Examples

      {:ok, cards} = Payjp.Cards.all(:customer, customer_id, accum, since, key)

  """
  def all(owner_type, owner_id, key, accum, opts) do
    case Payjp.Util.list_raw("#{endpoint_for_entity(owner_type, owner_id)}", key, opts) do
      {:ok, resp}  ->
        case resp[:has_more] do
          true ->
            last_sub = List.last( resp[:data] )
            all(owner_type, owner_id, key, resp[:data] ++ accum, until: last_sub["created"], limit: @max_fetch_size)
          false ->
            result = resp[:data] ++ accum
            {:ok, result}
        end
      {:error, err} -> raise err
    end
  end
end
