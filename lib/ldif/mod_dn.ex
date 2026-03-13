defmodule LDIF.ModDN do
  @moduledoc false
  
  alias __MODULE__
  alias LDIF.DNUtils
  alias LDIF.Entry

  @type t :: %__MODULE__{
               dn: binary(),
               deleteoldrdn: boolean(),
               newsuperior: nil | binary(),
               newrdn: nil | binary(),
             }


  #@derive Jason.Encoder
  defstruct [
    dn: nil,
    deleteoldrdn: true,
    newsuperior: nil,
    newrdn: nil
  ]

  @spec new(dn :: binary(), attributes :: map()) :: struct()
  def new(dn, changes) do

    changes = Map.delete(changes, "dn")
              |> Map.delete("changetype")

    [newrdn] = Map.get(changes, "newrdn", [nil])
    [newsuperior] = Map.get(changes, "newsuperior", [nil])
    deleteoldrdn = Map.get(changes, "deleteoldrdn") == ["1"] or Map.get(changes, "deleteoldrdn") == true

    %ModDN{dn: dn, newsuperior: newsuperior, deleteoldrdn: deleteoldrdn, newrdn: newrdn}
  end

  @spec apply_to(change :: struct(), entry :: %Entry{} | nil) :: list(%Entry{})
  def apply_to(change, entry) do
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
        dn == entry.dn -> [entry]
        change.deleteoldrdn -> [%{entry | dn: dn}]
        true -> [%{entry | dn: dn}, entry]
      end

    else
      [entry]
    end
  end

  defimpl LDIF.Change, for: LDIF.ModDN do
    def apply_to_entry(change, entry) do
      ModDN.apply_to(change, entry)
    end
  end

end
