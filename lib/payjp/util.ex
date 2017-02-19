defmodule Payjp.Util do
  def datetime_from_timestamp(ts) when is_binary ts do
    ts = case Integer.parse ts do
      :error -> 0
      {i, _r} -> i
    end
    datetime_from_timestamp ts
  end

  def datetime_from_timestamp(ts) when is_number ts do
    {{year, month, day}, {hour, minutes, seconds}} = :calendar.gregorian_seconds_to_datetime ts
    {{year + 1970, month, day}, {hour, minutes, seconds}}
  end

  def datetime_from_timestamp(nil) do
    datetime_from_timestamp 0
  end

  def string_map_to_atoms([string_key_map]) do
    string_map_to_atoms string_key_map
  end

  def string_map_to_atoms(string_key_map) do
    for {key, val} <- string_key_map, into: %{}, do: {String.to_atom(key), val}
  end

  def handle_payjp_response(res) do
    cond do
      res["error"] -> {:error, res}
      res["data"] -> {:ok, Enum.map(res["data"], &Payjp.Util.string_map_to_atoms &1)}
      true -> {:ok, Payjp.Util.string_map_to_atoms res}
    end
  end

  # returns the full response in {:ok, response}
  # this is useful to access top-level properties
  def handle_payjp_full_response(res) do
    cond do
      res["error"] -> {:error, res}
      true -> {:ok, Payjp.Util.string_map_to_atoms res}
    end
  end

  def list_raw( endpoint, opts \\ []) do
    defaults = [limit: 10, offset: nil, since: 0, until: nil]
    opts = Keyword.merge(defaults, opts)
    list_raw endpoint, Payjp.config_or_env_key, opts
  end

  def list_raw( endpoint, key, opts)  do
    q = "#{endpoint}?#{opts |> Enum.filter(fn{_, v} -> v end) |> URI.encode_query}"

    Payjp.make_request_with_key(:get, q, key )
    |> Payjp.Util.handle_payjp_full_response
  end

  def list( endpoint, key, opts) do
    list_raw endpoint, key, opts
  end

  def list( endpoint, opts \\ []) do
    defaults = [limit: 10, offset: nil, since: 0, until: nil]
    opts = Keyword.merge(defaults, opts)

    list endpoint, Payjp.config_or_env_key, opts
  end
end
