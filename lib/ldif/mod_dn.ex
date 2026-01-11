defmodule LDIF.ModDN do
  @moduledoc """
  Documentation for `Ldif`.
  """

  alias __MODULE__
  alias LDIF.DNUtils

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
    if DNUtils.normalize_dn(change.dn) == DNUtils.normalize_dn(entry.dn) do

      dn = change.dn
      dn = if change.newrdn do
        DNUtils.replace_rdn(dn, change.newrdn)
      else
        dn
      end

      dn = if change.newsuperior do
        DNUtils.replace_superior(dn, change.newsuperior)
      else
        dn
      end

      cond do
        dn == entry.dn -> entry
        change.deleteoldrdn -> %{entry | dn: dn}
        true -> [%{entry | dn: dn}, entry]
      end

    else
      entry
    end
  end

  defimpl LDIF.Change, for: LDIF.ModDN do
    def apply(change, entry) do
      ModDN.apply(change, entry)
    end
  end

end
