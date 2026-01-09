defmodule LDIF.ModRDN do
  @moduledoc """
  Documentation for `Ldif`.
  """

  alias __MODULE__

  @changetypes [:modify, :delete, :add, :modrdn, :moddn]

  #@derive Jason.Encoder

  defstruct [
    dn: nil,
    newrdn: nil,
    deleteoldrdn: true,
  ]

  def new(dn, changes) do
    changes = Map.delete(changes, "dn")
              |> Map.delete("changetype")

    [newrdn] = Map.get(changes, "newrdn")
    deleteoldrdn = Map.get(changes, "deleteoldrdn") == ["1"]

    %ModRDN{dn: dn, newrdn: newrdn, deleteoldrdn: deleteoldrdn}
  end

end
