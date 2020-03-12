defmodule Tbot.Strategies do
  @moduledoc """
  Gathers strategies for entering/exiting trades
  """
  alias Tbot.Technical.MovingAverage

  @breakout_weight 4
  @exp_moving_avg_cross_weight 5

  @spec exp_moving_avg_cross([float], integer, integer) :: integer
  def exp_moving_avg_cross(prices, fast_window, slow_window) do
    [fast_ema, prev_fast_ema | _] = MovingAverage.ema(prices, fast_window)
    [slow_ema, prev_slow_ema | _] = MovingAverage.ema(prices, slow_window)

    with true <- prev_fast_ema <= prev_slow_ema,
         true <- fast_ema > slow_ema do
      @exp_moving_avg_cross_weight
    else
      false ->
        with true <- prev_fast_ema >= prev_slow_ema,
             true <- fast_ema < slow_ema do
          -@exp_moving_avg_cross_weight
        else
          false -> 0
        end
    end
  end

  @doc """
  Braekout strategy for opening or closing positions.
  if the result is greater then 0 that it gives signal to buy, else sell, 0 means skip
  """
  @spec breakout(list(float), pos_integer, :long | :short | :none) :: integer
  def breakout(prices, window, _last_position = :short), do: breakout_long(prices, window)
  def breakout(prices, window, _last_position = :long), do: breakout_short(prices, window)
  def breakout(prices, window, _last_position = :none) do
    breakout_long(prices, window) + breakout_short(prices, window)
  end

  @spec breakout_long(list(float), pos_integer) :: integer
  defp breakout_long([latest_price | prices], window) do
    max_price =
      prices
      |> Enum.take(window)
      |> Enum.max()

    case latest_price > max_price do
      true -> @breakout_weight
      false -> 0
    end
  end

  @spec breakout_short(list(float), pos_integer) :: integer
  defp breakout_short([latest_price | prices], window) do
    min_price =
      prices
      |> Enum.take(window)
      |> Enum.min()

    case latest_price < min_price do
      true -> -@breakout_weight
      false -> 0
    end
  end
end
