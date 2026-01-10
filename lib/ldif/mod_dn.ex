defmodule LDIF.ModDN do
  @moduledoc """
  Documentation for `Ldif`.
  """

  alias __MODULE__

  #@derive Jason.Encoder
  defstruct [
    dn: nil,
    deleteoldrdn: true,
    newsuperior: nil
  ]

  def new(dn, changes) do

    changes = Map.delete(changes, "dn")
              |> Map.delete("changetype")

    [newsuperior] = Map.get(changes, "newsuperior")
    deleteoldrdn = Map.get(changes, "deleteoldrdn") == ["1"]

    %ModDN{dn: dn, newsuperior: newsuperior, deleteoldrdn: deleteoldrdn}
  end

#  def change(change, entry)

end
