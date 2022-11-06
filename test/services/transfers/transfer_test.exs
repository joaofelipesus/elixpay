defmodule Services.Transfers.TransferTest do
  use ExUnit.Case

  describe "call/4" do
    setup do
      Elixpay.setup("accounts_test.txt", "transactions_test.txt")
    end

    test "create a new transaction" do
      {:ok, receiving} = Account.create("111", 0.0, "accounts_test.txt")
      {:ok, transfering} = Account.create("222", 42.0, "accounts_test.txt")
      amount = 10

      Services.Transfers.Transfer.call(
        amount,
        transfering,
        receiving,
        "transactions_test.txt",
        "accounts_test.txt"
      )

      transactions = Transaction.read_transactions("transactions_test.txt")

      assert length(transactions) == 1
    end

    test "update transfer account amount" do
      {:ok, receiving} = Account.create("111", 0.0, "accounts_test.txt")
      {:ok, transfering} = Account.create("222", 42.0, "accounts_test.txt")
      amount = 10

      Services.Transfers.Transfer.call(
        amount,
        transfering,
        receiving,
        "transactions_test.txt",
        "accounts_test.txt"
      )

      account = Account.find(transfering.id, "accounts_test.txt")
      assert account.amount == 32.0
    end

    test "update received account amount" do
      {:ok, receiving} = Account.create("111", 0.0, "accounts_test.txt")
      {:ok, transfering} = Account.create("222", 42.0, "accounts_test.txt")
      amount = 10

      Services.Transfers.Transfer.call(
        amount,
        transfering,
        receiving,
        "transactions_test.txt",
        "accounts_test.txt"
      )

      account = Account.find(receiving.id, "accounts_test.txt")
      assert account.amount == 10
    end
  end
end
