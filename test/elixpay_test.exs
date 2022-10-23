defmodule ElixpayTest do
  use ExUnit.Case
  doctest Elixpay

  describe "setup" do
    setup do
      File.rm("accounts.txt")
    end

    test "creates file accounts.txt" do
      Elixpay.setup()

      assert File.exists?("accounts.txt") == true
    end

    test "start accounts.txt file with an empty array" do
      Elixpay.setup()

      {:ok, file_content} = File.read("accounts.txt")
      assert :erlang.binary_to_term(file_content) == []
    end
  end
end
