defmodule LDIF.ModDN do
  @moduledoc """
  Documentation for `Ldif`.
  """

  alias __MODULE__

  #@derive Jason.Encoder
  defstruct [
    dn: nil,
    deleteoldrdn: true,
    newsuperior: nil,
    newrdn: nil
  ]

  def new(dn, changes) do

    changes = Map.delete(changes, "dn")
              |> Map.delete("changetype")

    [newrdn] = Map.get(changes, "newrdn", [nil])
    [newsuperior] = Map.get(changes, "newsuperior", [nil])
    deleteoldrdn = Map.get(changes, "deleteoldrdn") == ["1"]

    %ModDN{dn: dn, newsuperior: newsuperior, deleteoldrdn: deleteoldrdn, newrdn: newrdn}
  end

  def apply(change, entry) do
    IO.puts "ModDN"
    entry
  end

  defimpl LDIF.Change, for: LDIF.ModDN do
    def apply(change, entry) do
      ModDN.apply(change, entry)
    end
  end

end
