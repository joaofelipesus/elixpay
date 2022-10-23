defmodule AccountTest do
  use ExUnit.Case

  describe "Account struct" do
    test "return an Struct with default values" do
      result = %Account{}

      assert result.id == nil
      assert result.pix_key == nil
      assert result.amount == 0
    end
  end

  describe "read_accounts/0" do
    test "returns an list with %Account{} structs" do
      Elixpay.setup("accounts_test.txt")

      Account.create("111", 100.0, "accounts_test.txt")

      result = Account.read_accounts("accounts_test.txt")
      assert length(result) == 1

      account = Enum.at(result, 0)
      assert account.pix_key == "111"
      assert account.amount == 100.0
    end
  end

  describe "create/2" do
    test "return ok and save account register when there are no matching pix_key" do
      Elixpay.setup("accounts_test.txt")

      {:ok, account} = Account.create("111", 100.0, "accounts_test.txt")

      assert account.__struct__ == Account
    end

    test "returns error when there is already an account with received pix key" do
      Elixpay.setup("accounts_test.txt")

      Account.create("111", 100.0, "accounts_test.txt")
      result = Account.create("111", 100.0, "accounts_test.txt")

      assert result == {:error, "Pix key already related to an account"}
    end
  end

  describe "get_account_by_pix_key" do
    setup do
      Elixpay.setup("accounts_test.txt")
    end

    test "return an %Account{} when received pix key matches with an register" do
      Account.create("111", 42.0, "accounts_test.txt")

      result = Account.get_account_by_pix_key("111", "accounts_test.txt")

      assert result.__struct__ == Account
    end

    test "return nil when there are no account with received pix_key" do
      result = Account.get_account_by_pix_key("111", "accounts_test.txt")

      assert result == nil
    end
  end

  describe "find/1" do
    setup do
      Elixpay.setup("accounts_test.txt")
    end

    test "return an %Account{} when received pix key matches with an register" do
      {:ok, account} = Account.create("111", 42.0, "accounts_test.txt")

      result = Account.find(account.id, "accounts_test.txt")

      assert result.__struct__ == Account
    end

    test "return nil when there are no account with received pix_key" do
      result = Account.find("111", "accounts_test.txt")

      assert result == nil
    end
  end
end
