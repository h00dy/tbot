defmodule Tbot.Fetcher do
  use Timex
  alias Tbot.Equity
  alias Tbot.Fetcher.{AVClient, Candle, Data}

  @doc """
  Fetches Intraday data for a single equity
  """
  @spec fetch_time_series_data(Equity.t()) :: Data.t()
  def fetch_time_series_data(equity, interval \\ 60) do
    candles =
      AVClient.get_intraday(equity.name, interval)
      |> Map.get("Time Series (#{interval}min)")
      |> serialize_time_series_data()

    %Data{equity: equity, candles: candles}
  end

  defp serialize_time_series_data(time_series_data) do
    time_series_data
    |> Enum.map(fn {date_time, ticker} ->
      %Candle{
        date: date_time |> Timex.parse!("%F %T", :strftime) |> DateTime.from_naive!("Etc/UTC"),
        open: ticker["1. open"] |> String.to_float(),
        high: ticker["2. high"] |> String.to_float(),
        low: ticker["3. low"] |> String.to_float(),
        close: ticker["4. close"] |> String.to_float(),
        volume: ticker["5. volume"] |> String.to_integer()
      }
    end)
    |> Enum.sort({:desc, Candle})
  end
end
