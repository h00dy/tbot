defmodule Tbot.Account do
  @moduledoc """
  Holds Account info
  """

  @doc """
  Initialize :account table and setes inital capital capital_value

  ## Examples

      iex> Tbot.Account.init()
      true
      iex> Tbot.Account.get_capital()
      {:capital, 5000}

  """
  def init do
    if :ets.whereis(:account) != :undefined do
      :ets.delete(:account)
    end
    :ets.new(:account, [:set, :protected, :named_table])
    true = :ets.insert(:account, {:capital, Application.get_env(:tbot, :capital, 5000)})
  end

  @doc """
  Updates the value of a capital

  ## Examples

      iex> Tbot.Account.init()
      true
      iex> Tbot.Account.update_capital(10_000)
      true
      iex> Tbot.Account.get_capital()
      {:capital, 10_000}

  """
  @spec update_capital(float) :: true | false
  def update_capital(new_capital_value) do
    :ets.insert(:account, {:capital, new_capital_value})
  end

  @spec get_capital() :: {:capital, float}
  def get_capital do
    [capital_value] = :ets.lookup(:account, :capital)
    capital_value
  end
end
