defmodule Tbot.Fetcher.Data do
  alias Tbot.Equity

  @type t :: %__MODULE__{equity: Equity.t(), candles: nonempty_list(Tbot.Fetcher.Candle.t())}

  defstruct [:equity, :candles]
end

defmodule Tbot.Fetcher.Candle do
  @type t :: %__MODULE__{
          date: DateTime.t(),
          open: float,
          high: float,
          close: float,
          low: float,
          volume: integer
        }

  defstruct [:date, :open, :close, :low, :high, :volume]

  def compare(candle1, candle2) do
    DateTime.compare(candle1.date, candle2.date)
  end
end
