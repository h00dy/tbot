defmodule Tbot.Runner do
  @moduledoc """
  Main functions to run Trading Bot
  """
  alias Tbot.Fetcher

  @doc """
  Runs the whole process of evalutaing stocks.
  Step 1. Update the list of stocks that we are evaluating
  Step 2. Retrive data for each stock with their technical indicators
  Step 3. Check if there are any open positions, that can be closed due to fullfiling any of the exit rules
  Step 4. Check if there are positive conditions to open a new position
  """
  def run do
    update_watchlist()
    |> Enum.each(&check_equity/1)
  end

  def check_equity(equity) do
    equity
    |> fetch_equity_data()
    |> check_exit_conditions()
    |> check_enter_conditions()
  end

  @spec update_watchlist() :: list(String.t)
  defp update_watchlist(), do: ["AAPL"]

  defp fetch_equity_data(equity_data), do: Fetcher.fetch_time_series_data(equity_data)

  defp check_exit_conditions(equity_data), do: equity_data

  defp check_enter_conditions(equity_data), do: equity_data

end
