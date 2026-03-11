defmodule LDIF.Delete do
  @moduledoc """
  Documentation for `Ldif`.
  """

  alias __MODULE__
  alias LDIF.DNUtils

  #@derive Jason.Encoder
  defstruct [
    dn: nil
  ]

  def new(dn, changes) do
    Map.delete(changes, "dn")
    |> Map.delete("changetype")
    %Delete{dn: dn}
  end

  def apply_to(change, entry) do
    if DNUtils.normalize_dn(change.dn) == DNUtils.normalize_dn(entry.dn) do
      []
    else
      [entry]
    end
  end

  defimpl LDIF.Change, for: LDIF.Delete do
    def apply_to_entry(change, entry) do
      Delete.apply_to(change, entry)
    end
  end

end
