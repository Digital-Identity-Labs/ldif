defmodule LDIF.Add do
  @moduledoc """
  Documentation for `Ldif`.
  """

  alias __MODULE__

  #@derive Jason.Encoder
  defstruct [
    dn: nil,
    attributes: %{}
  ]

  def new(dn, attributes) do
    changes = Map.delete(attributes, "dn") |> Map.delete("changetype")
    %Add{dn: dn, attributes: changes}
  end

  def apply(change, entry) do
    if DNUtils.normalize_dn(change.dn) == DNUtils.normalize_dn(entry.dn) do
      nil
    else
      nil
    end
  end

  defimpl LDIF.Change, for: LDIF.Add do
    def apply(change, entry) do
      Add.apply(change, entry)
    end
  end

end
