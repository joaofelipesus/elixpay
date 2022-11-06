defmodule Services.Transfers.ValidationsTest do
  use ExUnit.Case

  describe "call/3" do
    test "it returns error when receiving account is nil" do
      receiving_account = nil
      transfering_account = %Account{id: "6t5r4e3w2q", pix_key: "222", amount: 42.0}
      response = Services.Transfers.Validations.call(receiving_account, transfering_account, 15.0)
      assert response == {:error, "Received pix_key don't belong to any account."}
    end

    test "it returns error when transfering account is nil" do
      receiving_account = %Account{id: "1q2w3e4r5t", pix_key: "111", amount: 0.0}
      transfering_account = nil
      response = Services.Transfers.Validations.call(receiving_account, transfering_account, 15.0)
      assert response == {:error, "Received id don't belong to any account."}
    end

    test "it returns error when transfering account amount is insuficient" do
      receiving_account = %Account{id: "1q2w3e4r5t", pix_key: "111", amount: 0.0}
      transfering_account = %Account{id: "6t5r4e3w2q", pix_key: "222", amount: 42.0}

      response =
        Services.Transfers.Validations.call(receiving_account, transfering_account, 250.0)

      assert response == {:error, "Insufficient founds."}
    end

    test "it returns error when transfering and reciving accounts are the same" do
      receiving_account = %Account{id: "6t5r4e3w2q", pix_key: "222", amount: 42.0}
      transfering_account = %Account{id: "6t5r4e3w2q", pix_key: "222", amount: 42.0}
      response = Services.Transfers.Validations.call(receiving_account, transfering_account, 15.0)
      assert response == {:error, "Transfering and receiving accounts is the same."}
    end

    test "it returns success when all validations pass" do
      receiving_account = %Account{id: "1q2w3e4r5t", pix_key: "111", amount: 0.0}
      transfering_account = %Account{id: "6t5r4e3w2q", pix_key: "222", amount: 42.0}
      response = Services.Transfers.Validations.call(receiving_account, transfering_account, 15.0)
      assert response == {:success, "OK"}
    end
  end
end
