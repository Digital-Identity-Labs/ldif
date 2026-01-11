defmodule LDIF.Modify do
  @moduledoc """
  Documentation for `Ldif`.
  """

  alias __MODULE__
  alias LDIF.DNUtils

  @modifications ["replace", "add", "delete"]

  #@derive Jason.Encoder
  defstruct [
    dn: nil,
    modification: nil,
    attribute: nil,
    values: %{}
  ]

  def new(dn, changes) do
    changes = Map.delete(changes, "dn") |> Map.delete("changetype")
    {modification, [attribute | _]} = Enum.find(changes, fn {k, v} -> k in @modifications end)
    values = Map.get(changes, attribute, nil)
    %Modify{dn: dn, modification: String.to_atom(modification), attribute: attribute, values: values}
  end

  def apply(change, entry) do
    if DNUtils.normalize_dn(change.dn) == DNUtils.normalize_dn(entry.dn) do
      modify(change, entry)
    else
      entry
    end
  end

  def modify(%{modification: :replace} = change, entry) do
    if is_nil(change.values) or Enum.empty?(change.values) do
      %{entry | attributes: Map.delete(entry.attributes, "#{change.attribute}")}
    else
      %{entry | attributes: Map.put(entry.attributes, "#{change.attribute}", change.values)}
    end
  end

  def modify(%{modification: :add} = change, entry) do
    old = Map.get(entry.attributes, "#{change.attribute}", [])
    new = Map.get(change, :values, [])
    values = List.uniq(old ++ new)

    %{entry | attributes: Map.put(entry.attributes, "#{change.attribute}", values)}
  end

  def modify(%{modification: :delete} = change, entry) do
    if Map.get(entry.attributes, "#{change.attribute}", false) do
      %{entry | attributes: Map.delete(entry.attributes, "#{change.attribute}")}
    else
      raise "Entry #{entry.dn} does not have a #{change.attribute} to delete!"
    end
  end

  def modify(%{modification: other} = change, entry) do
    raise "Unknown modification type #{other} for #{entry.dn}"
  end

  defimpl LDIF.Change, for: LDIF.Modify do
    def apply(change, entry) do
      Modify.apply(change, entry)
      |> List.wrap()
    end
  end

end
