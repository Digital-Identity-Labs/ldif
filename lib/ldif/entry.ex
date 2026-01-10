defmodule LDIF.Entry do
  @moduledoc """
  Documentation for `Ldif`.
  """

  alias __MODULE__
  alias LDIF.Utils

  #@derive Jason.Encoder
  defstruct [
    dn: nil,
    attributes: %{}
  ]

  def new(dn, attributes) do
    attributes = Map.delete(attributes, "dn")
    %Entry{dn: dn, attributes: attributes}
  end

  def add(entry, attribute, values) do
    old = Map.get(entry.attributes, attribute, [])
    %{entry | attributes: Map.put(entry.attributes, attribute, normlist(old ++ List.wrap(values)))}
  end

  def moddn(entry, dn) do
    %{entry | dn: dn}
  end

  def modrdn(entry, rdn) do
    dn = Utils.replace_rdn(entry.dn, rdn)
    %{entry | dn: dn}
  end

  def delete(entry, attribute) do
    %{entry | attributes: Map.delete(entry.attributes, attribute)}
  end

  def replace(entry, attribute, values) do
    %{entry | attributes: Map.put(entry.attributes, attribute, values)}
  end

  defp normlist(list) do
    list
    |> Enum.uniq()
  end

end
