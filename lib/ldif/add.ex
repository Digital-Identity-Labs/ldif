defmodule LDIF.Add do
  @moduledoc """
  Documentation for `Ldif`.
  """

  alias __MODULE__
  alias LDIF.Entry

  #@derive Jason.Encoder
  defstruct [
    dn: nil,
    attributes: %{}
  ]

  def new(dn, attributes) do
    changes = Map.delete(attributes, "dn") |> Map.delete("changetype")
    %Add{dn: dn, attributes: changes}
  end

  def apply_to(change, nil) do
    [Entry.new(change.dn, change.attributes)]
  end

  def apply_to(change, entry) do
    Add.apply_to(change, nil) ++ [entry]
  end

  defimpl LDIF.Change, for: LDIF.Add do
    def apply_to_entry(change, entry) do
      Add.apply_to(change, entry)
    end
  end

end
