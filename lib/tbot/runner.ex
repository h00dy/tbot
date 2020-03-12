defmodule Tbot.Runner do
  @moduledoc """
  Main functions to run Trading Bot
  """
  alias Tbot.{Account, Equity, Fetcher, Position, Strategies, Technical}

  require Logger

  @data_fercher Application.get_env(:tbot, :data_fetcher_module, Tbot.Fetcher)
  # @order Tbot.Benchmark
  @fast_ema_window 16
  @slow_ema_window 64
  @breakout_window 15

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

  @spec check_equity(Equity.t()) :: :ok
  def check_equity(equity) do
    equity
    |> fetch_equity_data()
    |> check_exit()
    |> check_enter()
  end

  @spec update_watchlist() :: list(Equity.t())
  def update_watchlist(), do: [%Equity{name: "AAPL", atr: 6.97}]

  @spec fetch_equity_data(Equity.t()) :: Fetcher.Data.t()
  defp fetch_equity_data(equity), do: @data_fercher.fetch_time_series_data(equity)

  @spec get_condition_status(Fetcher.Data.t()) :: :buy | :sell | :skip
  defp get_condition_status(fetched_data) do
    {_id, latest_position} = Position.get_latest_position(fetched_data.equity.name) || {0, %{type: :none}}
    weight =
      fetched_data.candles
      |> Enum.map(& &1.close)
      |> Strategies.exp_moving_avg_cross(@fast_ema_window, @slow_ema_window)

    breakout_weight =
      fetched_data.candles
      |> Enum.map(&(&1.close))
      |> Strategies.breakout(@breakout_window, latest_position.type)

    cond do
      weight + breakout_weight > 0 -> :buy
      weight + breakout_weight == 0 -> :skip
      weight + breakout_weight < 0 -> :sell
    end
  end

  @spec check_exit(Fetcher.Data.t()) :: Fetcher.Data.t()
  defp check_exit(%{equity: equity, candles: [latest_candle | _]} = fetched_data) do
    positions = Position.get_active_positions(equity.name)

    fetched_data
    |> get_condition_status()
    |> close_if_possible(positions, latest_candle)

    fetched_data
  end

  @spec close_if_possible(
          :skip | :buy | :sell,
          list({String.t(), Position.t()}),
          Fetcher.Candle.t()
        ) :: :ok
  defp close_if_possible(:skip, _positions, _latest_candle), do: :ok
  defp close_if_possible(_signal, [], _latest_candle), do: :ok

  defp close_if_possible(signal, [{_id, position}], latest_candle) do
    if signal != position.status do
      close_position(position, latest_candle)
    end

    :ok
  end

  @spec close_position(Position.t(), Fetcher.Candle.t()) :: :ok
  defp close_position(position, latest_candle) do
    pos =
      %Position{position | close_price: latest_candle.close, active: false, close_date: latest_candle.date}
      |> calculate_profit

    case position.type do
      :long -> adjust_capital(pos.size * latest_candle.close)
      :short -> adjust_capital(pos.profit)
    end

    Logger.info("[#{latest_candle.date}] Closing position #{inspect(pos)}")
    # Logger.debug(inspect(Account.get_capital()))

    pos
    |> Position.update_position()

    :ok
  end

  @spec calculate_profit(Position.t()) :: Position.t()
  defp calculate_profit(
         %Position{open_price: open, close_price: close, size: size, type: type} = position
       ) do
    delta =
      case type do
        :long -> (close - open) * size
        :short -> (open - close) * size
      end

    %Position{position | profit: delta}
  end

  @spec check_enter(Fetcher.Data.t()) :: :ok
  defp check_enter(%Fetcher.Data{equity: equity, candles: [latest_candle | _]} = fetched_data) do
    if Position.get_active_positions(equity.name) == [] do
      signal = get_condition_status(fetched_data)
      execute_trade(fetched_data.equity, latest_candle, signal)
    end
    :ok
  end

  @spec execute_trade(Equity.t(), Fetcher.Candle.t(), :buy | :sell | :skip) :: :ok
  defp execute_trade(_, _, :skip), do: :ok

  defp execute_trade(%{name: name} = equity, latest_candle, signal) do
    size = Technical.calculate_position_size(equity, latest_candle.close)
    position = Position.new(name)

    type =
      case signal do
        :buy ->
          adjust_capital(-size * latest_candle.close)
          :long

        :sell ->
          :short
      end

    pos = %Position{
      position
      | size: size,
        open_price: latest_candle.close,
        status: signal,
        type: type,
        open_date: latest_candle.date
    }

    # |> @order.make_order()
    Logger.info("[#{latest_candle.date}] Opening position #{inspect(pos)}")

    pos
    |> Position.update_position()

    :ok
  end

  @spec adjust_capital(float) :: true | false
  defp adjust_capital(capital_change) do
    {:capital, capital} = Account.get_capital()
    Account.update_capital(capital + capital_change)
  end
end
