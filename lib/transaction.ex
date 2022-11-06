defmodule Transaction do
  @accounts_repo "accounts.txt"
  @transactions_repo "transactions.txt"

  defstruct id: nil,
            from_account: nil,
            to_account: nil,
            status: nil,
            amount: nil,
            error_message: nil,
            key_used: nil,
            created_at: nil

  def transaction_repo, do: @transactions_repo

  @doc """
  Perform an transfer between accounts

  ## Params

  - from[String]: id of transfering account.
  - pix_key[String]: pix key of receiving account.
  - amount[Float]: value of the transaction.
  """
  def transfer(
        from,
        pix_key,
        amount,
        accounts_repo \\ Account.accounts_repo,
        transactions_repo \\ @transactions_repo
      ) do
    receiving_account = Account.get_account_by_pix_key(pix_key, accounts_repo)
    transfering_account = Account.find(from, accounts_repo)

    {status, message} =
      Services.Transfers.Validations.call(
        receiving_account,
        transfering_account,
        amount
      )

    case {status, message} do
      {:success, _message} ->
        transaction =
          transaction_builder(amount, transfering_account.id, receiving_account.id, pix_key)

        write(transaction, transactions_repo)
        # TODO: update account amounts.
        {:ok, transaction}

      {:error, message} ->
        Services.Transfers.TransactionErrorBuilder.call(
          transfering_account,
          receiving_account,
          amount,
          pix_key,
          message
        )
        |> write(transactions_repo)

        {:error, message}
    end
  end

  def history(
        account_id,
        accounts_repo \\ @accounts_repo,
        transactions_repo \\ @transactions_repo
      ) do
    account = Account.find(account_id, accounts_repo)

    case account do
      nil ->
        {:error, "Account don't exist"}

      %Account{} ->
        IO.puts("+--------------------------------------|-----------|-------+")
        IO.puts("|                  ID                  |   STATUS  | VALUE |")
        IO.puts("+--------------------------------------|-----------|-------+")

        read_transactions(transactions_repo)
        |> Enum.filter(fn transaction ->
          transaction.from_account == account_id || transaction.to_account == account_id
        end)
        |> Enum.sort_by(& &1.created_at, Date)
        |> Enum.each(fn transaction ->
          color = status_color(transaction.status)

          IO.puts(
            "| #{transaction.id} | #{color} #{transaction.status} #{reset_color()} | #{transaction_kind(account_id, transaction)} |"
          )
        end)
    end
  end

  @doc """
  Return trabsactions from received repository.
  """
  def read_transactions(repository_name \\ @transactions_repo) do
    {:ok, transactions} = File.read(repository_name)
    :erlang.binary_to_term(transactions)
  end

  def write(transaction, repository_name) do
    transactions = read_transactions(repository_name) ++ [transaction]
    binary_transactions = :erlang.term_to_binary(transactions)
    File.write(repository_name, binary_transactions)
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

  defp status_color(status) do
    case status do
      :success -> IO.ANSI.green()
      :error -> IO.ANSI.red()
    end
  end

  defp reset_color do
    IO.ANSI.white()
  end

  defp transaction_kind(history_id, transaction) do
    cond do
      history_id == transaction.from_account ->
        "#{IO.ANSI.blue()} +#{transaction.amount} #{reset_color()}"

      history_id == transaction.to_account ->
        "#{IO.ANSI.yellow()} -#{transaction.amount} #{reset_color()}"
    end
  end
end
