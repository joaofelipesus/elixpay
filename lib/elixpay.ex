defmodule Elixpay do
  @moduledoc """
  Documentation for `Elixpay`.
  """

  @default_value :erlang.term_to_binary([])

  @doc """
  Creates files used to persist data.

  Created files:
    - accounts.txt
  """
  def setup do
    File.write("accounts.txt", @default_value)
  end
end
