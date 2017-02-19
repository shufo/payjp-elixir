defmodule Payjp.PlanTest do
  use ExUnit.Case
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  @moduletag :plan

  setup_all do
    use_cassette "plan_test/setup", match_requests_on: [:query, :request_body] do
      Payjp.Plans.delete_all
      Helper.create_test_plan "specific-test-plan"
      Helper.create_test_plan "specific-test-plan1"
      on_exit fn ->
        use_cassette "plan_test/teardown", match_requests_on: [:query, :request_body] do
          Payjp.Plans.delete "specific-test-plan"
          Payjp.Plans.delete "specific-test-plan1"
        end
      end
      :ok
    end
  end

  test "Creation" do
    use_cassette "plan_test/create", match_requests_on: [:query, :request_body] do
      case Payjp.Plans.create([id: "test-plan", name: "Test Plan", amount: 1000]) do
        {:ok, plan} -> assert plan.id == "test-plan"
        {:error, err} -> flunk err
      end
    end
  end

  test "Creation w/key" do
    use_cassette "plan_test/create_with_key", match_requests_on: [:query, :request_body] do
      case Payjp.Plans.create([id: "test-plan2", name: "Test Plan 2", amount: 1000], Payjp.config_or_env_key) do
        {:ok, plan} -> assert plan.id == "test-plan2"
        {:error, err} -> flunk err
      end
    end
  end

  test "Plan change" do
    use_cassette "plan_test/change", match_requests_on: [:query, :request_body] do
      case Payjp.Plans.change("test-plan",[name: "Other Plan"]) do
        {:ok, plan} -> assert plan.name == "Other Plan"
        {:error, err} -> flunk err
      end
    end
  end

  test "Plan change w/key" do
    use_cassette "plan_test/change_with_key", match_requests_on: [:query, :request_body] do
      case Payjp.Plans.change("test-plan",[name: "Other Plan2"], Payjp.config_or_env_key ) do
        {:ok, plan} -> assert plan.name == "Other Plan2"
        {:error, err} -> flunk err
      end
    end
  end

  test "Listing plans" do
    use_cassette "plan_test/list", match_requests_on: [:query, :request_body] do
      case Payjp.Plans.list() do
        {:ok, plans} -> assert length(plans) > 0
        {:error, err} -> flunk err
      end
    end
  end

  test "Listing plans w/key" do
    use_cassette "plan_test/list_with_key", match_requests_on: [:query, :request_body] do
      case Payjp.Plans.list(Payjp.config_or_env_key, 10) do
        {:ok, plans} -> assert length(plans) > 0
        {:error, err} -> flunk err
      end
    end
  end

  test "Retrieve plan" do
    use_cassette "plan_test/retrieve", match_requests_on: [:query, :request_body] do
      case Payjp.Plans.retrieve("specific-test-plan") do
        {:ok, plan} -> assert plan.id == "specific-test-plan"
        {:error, err} -> flunk err
      end
    end
  end

  test "Retrieve plan w/ key" do
    use_cassette "plan_test/retrieve_with_key", match_requests_on: [:query, :request_body] do
      case Payjp.Plans.retrieve("specific-test-plan1", Payjp.config_or_env_key) do
        {:ok, plan} -> assert plan.id == "specific-test-plan1"
        {:error, err} -> flunk err
      end
    end
  end

  test "Plan deletion" do
    use_cassette "plan_test/delete", match_requests_on: [:query, :request_body] do
      case Payjp.Plans.delete "test-plan" do
        {:ok, plan} -> assert plan.deleted
        {:error, err} -> flunk err
      end
    end
  end

  test "Plan deletion w/key" do
    use_cassette "plan_test/delete_with_key", match_requests_on: [:query, :request_body] do
      case Payjp.Plans.delete "test-plan2" do
        {:ok, plan} -> assert plan.deleted
        {:error, err} -> flunk err
      end
    end
  end

  test "All" do
    use_cassette "plan_test/all", match_requests_on: [:query, :request_body] do
      case Payjp.Plans.all  do
        {:ok, plans} -> assert plans
        {:error, err} -> flunk err
      end
    end
  end

  test "All w/key" do
    use_cassette "plan_test/all_with_key", match_requests_on: [:query, :request_body] do
      case Payjp.Plans.all Payjp.config_or_env_key do
        {:ok, plans} -> assert plans
        {:error, err} -> flunk err
      end
    end
  end

  test "Delete all" do
    use_cassette "plan_test/delete_all", match_requests_on: [:query, :request_body] do
      case Payjp.Plans.delete_all  do
        {:ok} ->
          use_cassette "plan_test/delete_all_count", match_requests_on: [:query, :request_body] do
            {:ok, plans} = Payjp.Plans.all
            assert length(plans) == 0
          end
        {:error, err} -> flunk err
      end
    end
  end

  test "Delete all w/key" do
    use_cassette "plan_test/delete_all_with_key", match_requests_on: [:query, :request_body] do
      Payjp.Plans.create([id: "test-plan1", name: "Test Plan1", amount: 1000])
      Payjp.Plans.create([id: "test-plan2", name: "Test Plan2", amount: 1000])

      case Payjp.Plans.delete_all Payjp.config_or_env_key do
        {:ok} ->
          use_cassette "plan_test/delete_all_with_key_count", match_requests_on: [:query, :request_body] do
            {:ok, plans} = Payjp.Plans.all
            assert length(plans) == 0
          end
        {:error, err} -> flunk err
      end
    end
  end
end
