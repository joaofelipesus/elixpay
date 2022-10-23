defmodule Account do
  defstruct id: nil, pix_key: nil, amount: 0.0

  @repository_name "accounts.txt"

  @doc """
  Create a new account if there is no previous register with same id or pix_key.

  ## Params

  - pix_key[String] -> key used to identify an account.
  - amount[Float] -> value transfered from an account to another.
  """
  def create(pix_key, amount, repository_name \\ @repository_name) do
    case get_account_by_pix_key(pix_key, repository_name) do
      %Account{} -> {:error, "Pix key already related to an account"}
      nil ->
        %__MODULE__{id: UUID.uuid4(), pix_key: pix_key, amount: amount}
        |> write(repository_name)
        {:ok, "Account created with success"}
    end
  end

  @doc """
  Return accounts from received repository.
  """
  def read_accounts(repository_name \\ @repository_name) do
    {:ok, accounts} = File.read(repository_name)
    :erlang.binary_to_term(accounts)
  end

  defp write(account, repository_name) do
    accounts = read_accounts(repository_name) ++ [account]
    binary_accounts = :erlang.term_to_binary(accounts)
    File.write(repository_name, binary_accounts)
  end

  defp get_account_by_pix_key(pix_key, repository_name) do
    read_accounts(repository_name)
    |> Enum.find(fn account -> account.pix_key == pix_key end)
  end
end