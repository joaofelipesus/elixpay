defmodule Services.Transfers.TransactionErrorBuilder do
  @doc """
  Build transaction with error, it is useful to handle cases where transaction has error status

  ## Params
  transfering_account[Account]
  receiving_account[Account]
  amount[Float]: transaction amount.
  pix_key[String]: pix key used to transfer.
  message[String]: error message.
  """
  def call(transfering_account, receiving_account, amount, pix_key, message) do
    cond do
      transfering_account == nil ->
        %Transaction{
          id: UUID.uuid4(),
          amount: amount,
          status: :error,
          error_message: message,
          from_account: nil,
          to_account: receiving_account.id,
          key_used: pix_key,
          created_at: DateTime.utc_now()
        }

      receiving_account == nil ->
        %Transaction{
          id: UUID.uuid4(),
          amount: amount,
          status: :error,
          error_message: message,
          from_account: transfering_account.id,
          to_account: nil,
          key_used: pix_key,
          created_at: DateTime.utc_now()
        }

      true ->
        %Transaction{
          id: UUID.uuid4(),
          amount: amount,
          status: :error,
          error_message: message,
          from_account: transfering_account.id,
          to_account: receiving_account.id,
          key_used: pix_key,
          created_at: DateTime.utc_now()
        }
    end
  end
end
