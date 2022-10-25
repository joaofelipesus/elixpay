defmodule TrannsactionTest do
  use ExUnit.Case

  setup do
    Elixpay.setup("accounts_test.txt", "transactions_test.txt")
  end

  describe "transfer" do
    test "return error when there are no account with received pix_key" do
      {:ok, account} = Account.create("111", 42.0, "accounts_test.txt")

      result =
        Transaction.transfer(
          account.id,
          "3333",
          500,
          "accounts_test.txt",
          "transactions_test.txt"
        )

      assert result == {:error, "Received pix_key don't belong to any account."}
    end

    test "return error when received id don't belongs to any account" do
      Account.create("111", 42.0, "accounts_test.txt")
      Account.create("222", 0.0, "accounts_test.txt")

      result =
        Transaction.transfer("1q2w3e", "222", 500, "accounts_test.txt", "transactions_test.txt")

      assert result == {:error, "Received id don't belong to any account."}
    end

    test "return error when transfering account has no founds" do
      {:ok, transfeing_account} = Account.create("111", 42.0, "accounts_test.txt")
      Account.create("222", 0.0, "accounts_test.txt")

      result =
        Transaction.transfer(
          transfeing_account.id,
          "222",
          500,
          "accounts_test.txt",
          "transactions_test.txt"
        )

      assert result == {:error, "Insufficient founds."}
    end

    test "return ok and transaction when status is success" do
      {:ok, transfeing_account} = Account.create("111", 42.0, "accounts_test.txt")
      Account.create("222", 0.0, "accounts_test.txt")

      {:ok, transaction} =
        Transaction.transfer(
          transfeing_account.id,
          "222",
          10,
          "accounts_test.txt",
          "transactions_test.txt"
        )

      assert transaction.status == :success
    end
  end

  describe "history/3" do
    test "returns error message when account don't exist" do
      response = Transaction.history("1q2w3e", "accounts_test.txt", "transactions_test.txt")

      assert response == {:error, "Account don't exist"}
    end
  end
end
