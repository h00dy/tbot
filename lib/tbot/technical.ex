defmodule Tbot.Technical do
  @moduledoc """
  Collection of Technical indicators
  """

  alias Tbot.{Equity, Fetcher}

  @spec calculate_position_size(Equity.t(), float) :: integer
  def calculate_position_size(equity, price) do
    target_risk = 12
    instrument_risk = equity.atr * 14
    {:capital, capital} = Tbot.Account.get_capital()
    notional_exposure = target_risk * capital / instrument_risk
    (notional_exposure / price) |> trunc
  end

  @doc """
  Calculates ATR based on provided _candles.

  The first step in calculating ATR is to find a series of true range values for a security.
  The price range of an asset for a given trading day is simply its high minus its low.
  Meanwhile, the true range is more encompassing and is defined as:

  TR = Max[(H - L), Absolute(H - prevClose), Absolute(L - precClose)]

  ATR(n) = (TR(1) + ... + TR(n)) / n
  """
  @spec equity_atr(list(Fetcher.Candle.t()), Equity.t(), integer) :: Equity.t
  def equity_atr(candles, equity, n) do
    atr =
    candles
    |> Enum.take(n)
    |> do_equity_atr
    |> avg

    %Equity{equity | atr: atr}
  end

  @spec do_equity_atr(list(Fetcher.Candle.t())) :: list(float)
  defp do_equity_atr([%Fetcher.Candle{high: high, low: low}, %Fetcher.Candle{close: close}]) do
    [[high - low, abs(high - close), abs(low - close)] |> Enum.max]
  end

  defp do_equity_atr([%Fetcher.Candle{high: high, low: low} | tail]) do
    [prev_candle | _] = tail
    tr =
      [high - low, abs(high - prev_candle.close), abs(low - prev_candle.close)]
      |> Enum.max

    do_equity_atr(tail) ++ [tr]
  end

  defp avg(list_of_values), do: Enum.sum(list_of_values) / length(list_of_values)
end
