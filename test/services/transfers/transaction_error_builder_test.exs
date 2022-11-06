defmodule Services.Transfers.TransactionErrorBuilderTest do
  use ExUnit.Case

  describe "call/5" do
    test "when transfering account is nil it returns an transaction with from_account nil" do
      receiving_account = %Account{id: "1q2w3e4r5t", pix_key: "111", amount: 0.0}
      transfering_account = nil
      amount = 10
      pix_key = "222"
      message = "Received id don't belong to any account."

      response =
        Services.Transfers.TransactionErrorBuilder.call(
          transfering_account,
          receiving_account,
          amount,
          pix_key,
          message
        )

      assert response.from_account == nil
      assert response.amount == amount
      assert response.status == :error
      assert response.error_message == message
      assert response.to_account == receiving_account.id
      assert response.key_used == pix_key
    end

    test "when receiving account is nil it returns an transaction with to_account nil" do
      receiving_account = nil
      transfering_account = %Account{id: "6t5r4e3w2q", pix_key: "222", amount: 42.0}
      amount = 10
      pix_key = "222"
      message = "Received id don't belong to any account."

      response =
        Services.Transfers.TransactionErrorBuilder.call(
          transfering_account,
          receiving_account,
          amount,
          pix_key,
          message
        )

      assert response.from_account == transfering_account.id
      assert response.amount == amount
      assert response.status == :error
      assert response.error_message == message
      assert response.to_account == nil
      assert response.key_used == pix_key
    end

    test "when transfering account and receiving account isn't nil it build an full transaction" do
      receiving_account = %Account{id: "1q2w3e4r5t", pix_key: "111", amount: 0.0}
      transfering_account = %Account{id: "6t5r4e3w2q", pix_key: "222", amount: 42.0}
      amount = 10
      pix_key = "222"
      message = "Received id don't belong to any account."

      response =
        Services.Transfers.TransactionErrorBuilder.call(
          transfering_account,
          receiving_account,
          amount,
          pix_key,
          message
        )

      assert response.from_account == transfering_account.id
      assert response.amount == amount
      assert response.status == :error
      assert response.error_message == message
      assert response.to_account == receiving_account.id
      assert response.key_used == pix_key
    end
  end
end
