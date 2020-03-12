defmodule Tbot.Benchmark do
  @moduledoc """
  Back test tools, to check profitabiltiy of Tbot System
  """
  alias Tbot.{Equity, Fetcher, Position}

  @doc """
  returns data, neweset at tail
  [1,2,3,4,5,6,7,8,9,10] <- 10 is newest
  """
  @spec get_historical_data(Equity.t()) :: [Fetcher.Candle.t()]
  def get_historical_data(equity) do
    %Fetcher.Data{candles: candles, equity: _} = Fetcher.fetch_time_series_data(equity)
    candles |> Enum.reverse()
  end

  def init do
    if :ets.whereis(:test_data) != :undefined do
      :ets.delete(:test_data)
    end
    :ets.new(:test_data, [:set, :protected, :named_table])
  end

  def run_simulation(equities) do
    Tbot.Position.init()
    Tbot.Account.init()
    init()

    equities
    |> Enum.each(fn %{name: symbol} = equity ->
      {learning_period, test_data} =
        equity
        |> get_historical_data
        |> Enum.split(20)

      true = :ets.insert(:test_data, {symbol, learning_period |> Enum.reverse()})

      simulate_time(equity, test_data)
      |> summarize(symbol)
    end)
  end

  def fetch_time_series_data(equity) do
    [{_symbol, candles}] = :ets.lookup(:test_data, equity.name)
    %Fetcher.Data{candles: candles, equity: equity}
  end

  def make_order(position), do: position

  @spec simulate_time(Equity.t(), [Fetcher.Candle]) :: [Position.t()]
  defp simulate_time(equity, []) do
    Position.get_closed_positions(equity.name)
  end

  defp simulate_time(equity, [future_time | tail]) do
    [{_symbol, data}] = :ets.lookup(:test_data, equity.name)
    true = :ets.insert(:test_data, {equity.name, [future_time | data]})
    Tbot.Runner.check_equity(equity)

    simulate_time(equity, tail)
  end

  defp summarize(positions, symbol) do
    sum =
      positions
      |> Enum.reduce(0, fn {_id, position}, acc ->
        acc + position.profit
      end)

    IO.inspect("Summary for #{symbol}: #{sum}$")
  end
end
