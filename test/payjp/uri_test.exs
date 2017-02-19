defmodule Payjp.UriTest do
  use ExUnit.Case

  @moduletag :uri

  test "keyword list encoding" do
    assert Payjp.URI.encode_query([a: 1]) == "a=1"
    assert Payjp.URI.encode_query([a: 1, b: 2]) == "a=1&b=2"
    assert Payjp.URI.encode_query(["a": "1", "b": "2"]) == "a=1&b=2"
    assert Payjp.URI.encode_query([a: nil, b: nil]) == "a=&b="
    assert Payjp.URI.encode_query(["foo z": "true"]) == "foo+z=true"
    assert Payjp.URI.encode_query(["test &": "test &"]) == "test+%26=test+%26"
    assert Payjp.URI.encode_query([a: "4test ~1.x"]) == "a=4test+~1.x"
    assert Payjp.URI.encode_query([a: "poll:146%"]) == "a=poll%3A146%25"
    assert Payjp.URI.encode_query([a: "/\n+/ゆ"]) == "a=%2F%0A%2B%2F%E3%82%86"
    assert Payjp.URI.encode_query([a: "/\n+/ゆ"]) == "a=%2F%0A%2B%2F%E3%82%86"
  end

  test "nested list encoding" do
    assert Payjp.URI.encode_query([a: [a: 1]]) == "a[a]=1"
    assert Payjp.URI.encode_query([a: [b: 1]]) == "a[b]=1"
    assert Payjp.URI.encode_query([a: [b: [c: 1]]]) == "a[b][c]=1"
    assert Payjp.URI.encode_query([a: [b: ["test &": "test &"]]]) == "a[b][test+%26]=test+%26"
    assert Payjp.URI.encode_query([a: [a: "/\n+/ゆ"]]) == "a[a]=%2F%0A%2B%2F%E3%82%86"
    assert Payjp.URI.encode_query(%{a: [a: "test &"]}) == "a[a]=test+%26"
  end

  test "map list encoding" do
    assert Payjp.URI.encode_query(%{a: 1}) == "a=1"
    assert Payjp.URI.encode_query(%{a: 1, b: 2}) == "a=1&b=2"
    assert Payjp.URI.encode_query(%{"a": "1", "b": "2"}) == "a=1&b=2"
    assert Payjp.URI.encode_query(%{a: nil, b: nil}) == "a=&b="
    assert Payjp.URI.encode_query(%{"foo z": "true"}) == "foo+z=true"
    assert Payjp.URI.encode_query(%{"test &": "test &"}) == "test+%26=test+%26"
    assert Payjp.URI.encode_query(%{a: "4test ~1.x"}) == "a=4test+~1.x"
    assert Payjp.URI.encode_query(%{a: "poll:146%"}) == "a=poll%3A146%25"
    assert Payjp.URI.encode_query(%{a: "/\n+/ゆ"}) == "a=%2F%0A%2B%2F%E3%82%86"
    assert Payjp.URI.encode_query(%{a: "/\n+/ゆ"}) == "a=%2F%0A%2B%2F%E3%82%86"
  end
end
