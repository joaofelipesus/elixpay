defmodule Services.Transfers.Validations do
  @receiving_account_error_message "Received pix_key don't belong to any account."
  @transfering_account_error_message "Received id don't belong to any account."
  @insufitient_founds_error_message "Insufficient founds."
  @same_account_error_message "Transfering and receiving accounts is the same."

  @doc """
  Check if an account is eligible to make an transfer to another account

  ## Params

  - receiving_account[Account]: receiving account pix_key.
  - transfering_account[Account]: account id.
  - amount[Float]: value of transaction amount.
  """
  def call(receiving_account, transfering_account, amount) do
    cond do
      receiving_account == nil -> {:error, @receiving_account_error_message}
      transfering_account == nil -> {:error, @transfering_account_error_message}
      transfering_account.amount < amount -> {:error, @insufitient_founds_error_message}
      transfering_account.id == receiving_account.id -> {:error, @same_account_error_message}
      true -> {:success, "OK"}
    end
  end
end
