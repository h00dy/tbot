defmodule Tbot.Fetcher.Data do
  @type t :: %__MODULE__{name: String.t(), data: list}

  defstruct [:name, :data]
end

defmodule Tbot.Fetcher.Candle do
  @type t :: %__MODULE__{
          date: DateTime,
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
