defmodule Services.TransferService do
  @without_receiving_error_message "Received pix_key don't belong to any account."
  @without_transfering_error_message "Received id don't belong to any account."

  def transfer(
        from,
        pix_key,
        amount,
        accounts_repo \\ Account.accounts_repo(),
        # @transactions_repo
        transactions_repo \\ Transaction.transaction_repo()
      ) do
    receiving_account = Account.get_account_by_pix_key(pix_key, accounts_repo)
    transfering_account = Account.find(from, accounts_repo)
    {status, message} = validation(receiving_account, transfering_account, amount)

    case {status, message} do
      {:success, _message} ->
        transaction =
          transaction_builder(amount, transfering_account.id, receiving_account.id, pix_key)

        Transaction.write(transaction, transactions_repo)
        # TODO: update account amounts.
        {:ok, transaction}

      {:error, @without_transfering_error_message} ->
        transaction_without_transfering_builder(amount, receiving_account.id, pix_key)
        |> Transaction.write(transactions_repo)

        {:error, message}

      {:error, @without_receiving_error_message} ->
        transaction_without_receiver_builder(amount, transfering_account.id, pix_key)
        |> Transaction.write(transactions_repo)

        {:error, message}

      {:error, _message} ->
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
        |> Transaction.write(transactions_repo)

        {:error, message}
    end
  end

  defp validation(receiving_account, transfering_account, amount) do
    cond do
      receiving_account == nil -> {:error, "Received pix_key don't belong to any account."}
      transfering_account == nil -> {:error, "Received id don't belong to any account."}
      transfering_account.amount < amount -> {:error, "Insufficient founds."}
      true -> {:success, "OK"}
    end
  end

  defp transaction_builder(amount, transfering, receiving, pix_key) do
    %Transaction{
      id: UUID.uuid4(),
      amount: amount,
      status: :success,
      error_message: nil,
      from_account: transfering,
      to_account: receiving,
      key_used: pix_key,
      created_at: DateTime.utc_now()
    }
  end

  defp transaction_without_receiver_builder(amount, transfering_account, pix_key) do
    %Transaction{
      id: UUID.uuid4(),
      amount: amount,
      status: :error,
      error_message: @without_receiving_error_message,
      from_account: transfering_account,
      to_account: nil,
      key_used: pix_key,
      created_at: DateTime.utc_now()
    }
  end

  defp transaction_without_transfering_builder(amount, receiving_account, pix_key) do
    %Transaction{
      id: UUID.uuid4(),
      amount: amount,
      status: :error,
      error_message: @without_transfering_error_message,
      from_account: nil,
      to_account: receiving_account,
      key_used: pix_key,
      created_at: DateTime.utc_now()
    }
  end
end
