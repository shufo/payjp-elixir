ExUnit.start
#Payjp.start
ExUnit.configure [exclude: [disabled: true], seed: 0 ]

defmodule Helper do
  def create_test_plans do
    Payjp.Plans.create [id: "test-std", name: "Test Plan Standard", amount: 100, interval: "month"]
    Payjp.Plans.create [id: "test-dlx", name: "Test Plan Deluxe", amount: 1000, interval: "month"]
  end
  def create_test_plan id do
    Payjp.Plans.create [id: id, name: "Test Plan #{id}", amount: 100, interval: "month"]
  end
  def delete_test_plan id do
    Payjp.Plans.delete id
  end

  def delete_test_plans do
    Payjp.Plans.delete "test-std"
    Payjp.Plans.delete "test-dlx"
  end

  def create_test_token do
    params = [
      card: [
        number: "4242424242424242",
        exp_month: 12,
        exp_year: 2029,
        cvc: "123"
      ]
    ]
    {:ok, token} = Payjp.Tokens.create(params)
    token
  end

  def create_test_token(params) do
    {:ok, token} = Payjp.Tokens.create(params)
    token
  end

  def create_test_customer( email ) do
    new_customer = [
      email: "#{email}",
      description: "Test Account",
      card: [
        number: "4242424242424242",
        exp_month: 01,
        exp_year: 2018,
        cvc: 123,
        name: "Joe Test User"
      ]
    ]
    {:ok, res} = Payjp.Customers.create new_customer
    res
  end

  def create_test_account(email) do
    new_account = [
      email: email,
      managed: true,
      legal_entity: [
        type: "individual"
      ]
    ]
    {:ok, res} = Payjp.Accounts.create new_account
    res
  end
end
