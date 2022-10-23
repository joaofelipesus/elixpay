defmodule ElixpayTest do
  use ExUnit.Case
  doctest Elixpay

  describe "setup/1" do
    test "creates file accounts.txt" do
      Elixpay.setup("accounts_test.txt")

      assert File.exists?("accounts_test.txt") == true
    end

    test "start accounts.txt file with an empty array" do
      Elixpay.setup("accounts_test.txt")

      {:ok, file_content} = File.read("accounts_test.txt")
      assert :erlang.binary_to_term(file_content) == []
    end
  end
end
