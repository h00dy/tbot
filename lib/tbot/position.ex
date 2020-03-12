defmodule Tbot.Position do
  @moduledoc """
  Holds information about Poristions
  """

  @type t() :: %__MODULE__{
          id: String.t(),
          status: :buy | :sell | nil,
          symbol: String.t(),
          type: :long | :short | nil,
          size: integer | nil,
          open_price: float | nil,
          close_price: float | nil,
          open_date: DateTime.t() | nil,
          close_date: DateTime.t() | nil,
          active: boolean,
          profit: float | nil,
        }

  defstruct [
    :id,
    :status,
    :symbol,
    :type,
    :size,
    :open_price,
    :close_price,
    :open_date,
    :close_date,
    :profit,
    active: true,
  ]

  def new(symbol) do
    %__MODULE__{id: UUID.uuid1(), symbol: symbol}
  end

  @doc """
  Initialize :positions ETS table
  """
  @spec init() :: atom
  def init do
    if :ets.whereis(:positions) != :undefined do
      :ets.delete(:positions)
    end
    :ets.new(:positions, [:set, :protected, :named_table])
  end

  @doc """
  Returns a list of active Positions for given Symbol

  ## examples

      iex> Tbot.Position.init()
      iex> new_pos = Tbot.Position.new("AAPL")
      iex> Tbot.Position.update_position(new_pos)
      iex> [{id, _pos}] = Tbot.Position.get_active_positions("AAPL")
      iex> assert id == new_pos.id
  """
  @spec get_active_positions(String.t()) :: list({String.t, Tbot.Position.t()})
  def get_active_positions(symbol) do
    get_positions(symbol)
    |> Enum.filter(fn {_key, position} -> position.active == true end)
  end

  @spec get_closed_positions(String.t()) :: list(t())
  def get_closed_positions(symbol) do
    get_positions(symbol)
    |> Enum.filter(fn {_key, position} -> position.active == false end)
  end

  @spec update_position(t()) :: :ok
  def update_position(position) do
    positions_map =
      position.symbol
      |> get_positions
      |> Map.update(position.id, position, &(&1 = position))

    :ets.insert(:positions, {position.symbol, positions_map})

    :ok
  end

  @doc """
  Returns all positions for a given Symbol

  ## Examples

       iex> Tbot.Position.init()
       iex> position = Tbot.Position.new("AAPL")
       iex> Tbot.Position.update_position(position)
       iex> positions = Tbot.Position.get_positions("AAPL")
       iex> assert positions == %{position.id => position}
  """
  @spec get_positions(String.t) :: t() | %{}
  def get_positions(symbol) do
    case :ets.lookup(:positions, symbol) do
      [] -> %{}
      [{_symbol, position_map}] -> position_map
    end
  end

  @spec get_latest_position(String.t) :: t() | nil
  def get_latest_position(symbol) do
    symbol
    |> get_positions
    |> Enum.sort_by(fn {_id, position} -> position.open_date end, {:desc, DateTime})
    |> List.first
  end
end
