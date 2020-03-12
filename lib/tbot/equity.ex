defmodule Tbot.Equity do
  @moduledoc """
  Holds information about equity
  """

  @type t() :: %__MODULE__{
    name: String.t,
    atr: float

  }

  defstruct [:name, :atr]
end
