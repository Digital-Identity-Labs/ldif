defmodule LDIF.Delete do
  @moduledoc """
  Documentation for `Ldif`.
  """

  alias __MODULE__
  alias LDIF.DNUtils

  @changetypes
  #@derive Jason.Encoder
  defstruct [
    dn: nil
  ]

  def new(dn, changes) do
    changes = Map.delete(changes, "dn")
              |> Map.delete("changetype")
    %Delete{dn: dn}
  end

  def apply(change, entry) do
    if DNUtils.normalize_dn(change.dn) == DNUtils.normalize_dn(entry.dn) do
      nil
    else
      entry
    end
  end

  defimpl LDIF.Change, for: LDIF.Delete do
    def apply(change, entry) do
      Delete.apply(change, entry)
    end
  end

end
