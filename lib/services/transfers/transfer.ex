defmodule Services.Transfers.Transfer do
  @doc """
  Transfer and persist new amount values.

  ## Params

  amount[Float]: transaction amount
  transfering[%Account{}]
  receiving[%Account{}]
  """
  def call(
        amount,
        transfering,
        receiving,
        transaction_repo \\ Transaction.transaction_repo(),
        account_repo \\ Account.accounts_repo()
      ) do
    transaction = %Transaction{
      id: UUID.uuid4(),
      amount: amount,
      status: :success,
      error_message: nil,
      from_account: transfering,
      to_account: receiving,
      key_used: receiving.pix_key,
      created_at: DateTime.utc_now()
    }
    Transaction.write(transaction, transaction_repo)

    Account.add_amount(receiving, amount, account_repo)
    Account.subtract_amount(transfering, amount, account_repo)
    {:ok, transaction}
  end
end
