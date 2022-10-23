defmodule ElixpayTest do
  use ExUnit.Case
  doctest Elixpay

  describe "setup/1" do
    test "creates accounts and transactions files" do
      Elixpay.setup("accounts_test.txt", "transactions_test.txt")

      assert File.exists?("accounts_test.txt") == true
      assert File.exists?("transactions_test.txt") == true
    end

    test "start accounts.txt file with an empty array" do
      Elixpay.setup("accounts_test.txt", "transactions_test.txt")

      {:ok, accounts_content} = File.read("accounts_test.txt")
      assert :erlang.binary_to_term(accounts_content) == []

      {:ok, transactions_content} = File.read("transactions_test.txt")
      assert :erlang.binary_to_term(transactions_content) == []
    end
  end
end
