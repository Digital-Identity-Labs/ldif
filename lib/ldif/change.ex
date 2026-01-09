defmodule LDIF.Change do
  @moduledoc """
  Documentation for `Ldif`.
  """

  alias __MODULE__

  #@derive Jason.Encoder
  defstruct [
    dn: nil,
    type: :record,
    changes: %{}
  ]

  def new(dn, changes, type \\ :simple) do
    attributes = Map.delete(changes, "dn")
    %Change{dn: dn, changes: changes, type: type}
  end

end
