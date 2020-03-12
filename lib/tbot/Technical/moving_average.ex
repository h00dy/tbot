defmodule Tbot.Technical.MovingAverage do
  @moduledoc """
  Moving Average indicators
  """

  @doc """
  Calculates Exponential Moving Average, for n size window

  EMA=Price(t)×k+EMA(y)×(1−k)

  where:
  t=today
  y=yesterday
  N=number of days in EMA
  k=2÷(N+1)
  """
  @spec ema(list(float), integer) :: list(float)
  def ema(list, n) do
    list
    |> do_ema(calculate_k(n), [])
  end

  @spec do_ema(list(float), float, list(float)) :: list(float)
  defp do_ema([head | []], _k, _acc), do: [head]

  defp do_ema([head | tail], k, acc) do
    [prev_ema_value | new_acc] = do_ema(tail, k, acc)
    result = head * k + prev_ema_value * (1 - k)
    [result, prev_ema_value | new_acc]
  end

  @doc """
  Use if most recent data is in tail of list
  """
  @spec ema2(list(float), integer) :: list(float)
  def ema2(list, n) do
    list
    |> do_ema2(calculate_k(n), [])
  end

  defp do_ema2([head | []], k, [latest_ema | _] = emas) do
    [head * k + latest_ema * (1 - k) | emas]
  end

  defp do_ema2([head | tail], k, []), do: do_ema2(tail, k, [head])

  defp do_ema2([head | tail], k, [latest_ema | _t] = emas) do
    do_ema2(tail, k, [head * k + latest_ema * (1 - k) | emas])
  end

  defp calculate_k(n), do: 2 / (n + 1)
end
