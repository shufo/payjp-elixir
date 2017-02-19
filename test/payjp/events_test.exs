defmodule Payjp.EventsTest do
  use ExUnit.Case
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  @moduletag :event

  setup_all do
    use_cassette "events_test/setup", match_requests_on: [:query, :request_body] do
      customer1 = Helper.create_test_customer "events_test1@example.com"
      customer2 = Helper.create_test_customer "events_test2@example.com"
      customer3 = Helper.create_test_customer "events_test3@example.com"
      customer4 = Helper.create_test_customer "events_test4@example.com"
      customer5 = Helper.create_test_customer "events_test5@example.com"
      customer6 = Helper.create_test_customer "events_test6@example.com"
      on_exit fn ->
        use_cassette "events_test/teardown", match_requests_on: [:query, :request_body] do
          Payjp.Customers.delete customer1.id
          Payjp.Customers.delete customer2.id
          Payjp.Customers.delete customer3.id
          Payjp.Customers.delete customer4.id
          Payjp.Customers.delete customer5.id
          Payjp.Customers.delete customer6.id
        end
      end
    end
  end

  @tag disabled: false
  test "List works" do
    use_cassette "events_test/list", match_requests_on: [:query, :request_body] do
      case Payjp.Events.list limit: 20 do
        {:ok, events} ->
          assert length(events[:data]) > 0
          {:error, err} -> flunk err
      end
    end
  end

  @tag disabled: false
  test "List w/key works" do
    use_cassette "events_test/list_with_key", match_requests_on: [:query, :request_body] do
      case Payjp.Events.list Payjp.config_or_env_key, [] do
        {:ok, events} -> assert length(events[:data]) > 0
        {:error, err} -> flunk err
      end
    end
  end

  @tag disabled: false
  test "List w/paging works" do
    use_cassette "events_test/list_with_paging_and_key", match_requests_on: [:query, :request_body] do
      {:ok,events} = Payjp.Events.list Payjp.config_or_env_key, []

      case events[:has_more] do
        true ->
          last = List.last( events[:data] )
          case Payjp.Events.list Payjp.config_or_env_key, since: last["created"] do
            {:ok, events} -> assert length(events[:data]) > 0
            {:error,err} -> flunk err
          end
          false -> flunk "should have had more than 1 page. Check setup to make sure theres enough events for the test to run properly (5+)"
      end
    end
  end

  @tag disabled: false
  test "Get works" do
    use_cassette "events_test/get", match_requests_on: [:query, :request_body] do
      {:ok, events} = Payjp.Events.list
      evt = hd events[:data]
      case Payjp.Events.get evt["id"]  do
        {:ok, event} ->
          assert event[:object] == "event"
          {:error, err} -> flunk err
      end
    end
  end
  @tag disabled: false
  test "Get w/key works" do
    use_cassette "events_test/get_with_key", match_requests_on: [:query, :request_body] do
      {:ok, events} = Payjp.Events.list
      evt = hd events[:data]
      case Payjp.Events.get Payjp.config_or_env_key, evt["id"]   do
        {:ok, event} ->
          assert event[:object] == "event"
          {:error, err} -> flunk err
      end
    end
  end
end
