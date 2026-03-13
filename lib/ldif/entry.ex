defmodule LDIF.Entry do
  @moduledoc """
  Documentation for `Ldif`.
  """

  alias __MODULE__
  alias LDIF.DNUtils
  alias LDIF.AttrMapper

  @type t :: %__MODULE__{
               dn: binary(),
               attributes: map()
             }
             
  #@derive Jason.Encoder
  defstruct [
    dn: nil,
    attributes: %{}
  ]

  @spec new(dn :: binary(), attributes :: map()) :: %Entry{}
  def new(dn, attributes \\ %{}) do
    attributes = Map.delete(attributes, "dn")
    %Entry{dn: dn, attributes: attributes}
  end

  @spec dn(entry :: %Entry{}) :: binary()
  def dn(entry) do
    entry.dn
  end

  @spec ndn(entry :: %Entry{}) :: binary()
  def ndn(entry) do
    DNUtils.normalize_dn(entry.dn)
  end

  @spec rdn(entry :: %Entry{}) :: binary()
  def rdn(entry) do
    DNUtils.rdn(entry.dn)
  end

  @spec nrdn(entry :: %Entry{}) :: binary()
  def nrdn(entry) do
    DNUtils.nrdn(entry.dn)
  end

  @spec superior(entry :: %Entry{}) :: binary()
  def superior(entry) do
    DNUtils.superior(entry.dn)
  end

  @spec attributes(entry :: %Entry{}) :: map()
  def attributes(entry) do
    entry.attributes || %{}
  end

  @spec attribute(entry :: %Entry{}, attribute :: binary()) :: list()
  def attribute(entry, attribute) do
    attributes(entry)[attribute] || []
  end

  @spec get(entry :: %Entry{}, attribute :: binary()) :: list() | nil
  def get(entry, attribute) do
    attributes(entry)[attribute]
  end

  @spec add(entry :: %Entry{}, attribute :: binary(), values :: list()) :: %Entry{}
  def add(entry, attribute, values) do
    old = Map.get(entry.attributes, attribute, [])
    %{entry | attributes: Map.put(entry.attributes, attribute, normlist(old ++ List.wrap(values)))}
  end

  @spec merge_tagged(entry :: %Entry{}) :: %Entry{}
  def merge_tagged(entry) do
    attributes = entry.attributes
                 |> Enum.map(fn {k, v} -> {List.first(String.split(k, ";")), v} end)
                 |> Enum.group_by(fn {n, _v} -> n end, fn {_n, v} -> v end)
                 |> Enum.map(
                      fn {k, v} ->
                        {
                          k,
                          List.flatten(v)
                          |> Enum.uniq()
                        } end
                    )
                 |> Map.new()

    %Entry{entry | attributes: attributes}
  end

  @spec moddn(entry :: %Entry{}, dn :: binary()) :: %Entry{}
  def moddn(entry, dn) do
    %{entry | dn: dn}
  end

  @spec modrdn(entry :: %Entry{}, rdn :: binary()) :: %Entry{}
  def modrdn(entry, rdn) do
    dn = DNUtils.replace_rdn(entry.dn, rdn)
    %{entry | dn: dn}
  end

  @spec delete(entry :: %Entry{}, attribute :: binary()) :: %Entry{}
  def delete(entry, attribute) do
    %{entry | attributes: Map.delete(entry.attributes, attribute)}
  end

  @spec delete(entry :: %Entry{}, attribute :: binary(), value :: binary()) :: %Entry{}
  def delete(entry, attribute, value) do
    values = Map.get(entry.attributes, attribute, [])
             |> Enum.map(fn v -> if v == value, do: nil, else: v end)
             |> Enum.uniq()
             |> Enum.reject(&is_nil/1)

    %{entry | attributes: Map.put(entry.attributes, attribute, values)}
  end

  @spec replace(entry :: %Entry{}, attribute :: binary(), values :: list()) :: %Entry{}
  def replace(entry, attribute, values) do
    %{entry | attributes: Map.put(entry.attributes, attribute, values)}
  end

  @spec  replace(entry :: %Entry{}, attribute :: binary(), old_value :: binary(), new_value :: binary()) :: %Entry{}
  def replace(entry, attribute, old_value, new_value) do
    values = Map.get(entry.attributes, attribute, [])
             |> Enum.map(fn v -> if v == old_value, do: new_value, else: v end)
             |> Enum.reject(&is_nil/1)
             |> Enum.uniq()

    %{entry | attributes: Map.put(entry.attributes, attribute, values)}
  end

  @spec to_map(entry :: %Entry{}, opts :: keyword()) :: map()
  def to_map(entry, opts \\ []) do
    AttrMapper.entry_to_map(entry, opts)
  end

  #################

  @spec normlist(list :: list()) :: list()
  defp normlist(list) do
    list
    |> Enum.uniq()
  end

end
