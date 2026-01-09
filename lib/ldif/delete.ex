defmodule LDIF.Delete do
  @moduledoc """
  Documentation for `Ldif`.
  """

  alias __MODULE__

  @changetypes
  #@derive Jason.Encoder
  defstruct [
    dn: nil
  ]

  def new(dn, changes) do
    changes = Map.delete(changes, "dn") |> Map.delete("changetype")
    %Delete{dn: dn}
  end

end
