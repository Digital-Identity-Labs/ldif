defmodule LDIF.Entry do
  @moduledoc """
  `LIDF.Entry` provides a struct and various helper functions for working with normal LDIF/LDAP entries.
    
  
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

  @doc false
  @spec new(dn :: binary(), attributes :: map()) :: Entry.t()
  def new(dn, attributes \\ %{}) do
    attributes = Map.delete(attributes, "dn")
    %Entry{dn: dn, attributes: attributes}
  end

  @doc """
  Returns the DN (Distinguished Name) of the entry
  
  """
  @spec dn(entry :: Entry.t()) :: binary()
  def dn(entry) do
    entry.dn
  end

  @doc """
  Returns a normalized version of the DN (Distinguished Name) of the entry
  
  """
  @spec ndn(entry :: Entry.t()) :: binary()
  def ndn(entry) do
    DNUtils.normalize_dn(entry.dn)
  end

  @doc """
  Returns the RDN (Relative Distinguished Name) of the entry
  
  """
  @spec rdn(entry :: Entry.t()) :: binary()
  def rdn(entry) do
    DNUtils.rdn(entry.dn)
  end

  @doc """
  Returns a normalized version of the RDN (Relative Distinguished Name) of the entry
  
  """
  @spec nrdn(entry :: Entry.t()) :: binary()
  def nrdn(entry) do
    DNUtils.nrdn(entry.dn)
  end

  @doc """
  Returns the superior part of the entry's DN (this is the opposite of the RDN, the tail)
  
  """
  @spec superior(entry :: Entry.t()) :: binary()
  def superior(entry) do
    DNUtils.superior(entry.dn)
  end

  @doc """
  Returns all attributes as a map.
 
  Attribute names (the keys) will be strings.
  
  """
  @spec attributes(entry :: Entry.t()) :: map()
  def attributes(entry) do
    entry.attributes || %{}
  end

  @doc """
  Returns the values of the named attribute.
    
  Attribute names are strings. Values will usually be lists of strings. Empty or missing attributes will result
    in empty lists being returned.
  
  """
  @spec attribute(entry :: Entry.t(), attribute :: binary()) :: list()
  def attribute(entry, attribute) do
    attributes(entry)[attribute] || []
  end

  @doc """
  Returns the values of the named attribute.
    
  Attribute names are strings. Values will usually be lists of strings. Missing attributes will result in a nil
   being returned.
  
  """
  @spec get(entry :: Entry.t(), attribute :: binary()) :: list() | nil
  def get(entry, attribute) do
    attributes(entry)[attribute]
  end

  @doc """
  Adds a value to an attribute and returns a new Entry.
  
  If an attribute is missing it will be created.
  
  """
  @spec add(entry :: Entry.t(), attribute :: binary(), values :: list()) :: Entry.t()
  def add(entry, attribute, values) do
    old = Map.get(entry.attributes, attribute, [])
    %{entry | attributes: Map.put(entry.attributes, attribute, normlist(old ++ List.wrap(values)))}
  end

  @doc """
  Merge together all tagged attributes, returning a new Entry.
  
  """
  @spec merge_tagged(entry :: Entry.t()) :: Entry.t()
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

    %{entry | attributes: attributes}
  end

  @doc """
  Replaces the entire DN of the entry, returning a new Entry
  
  """
  @spec moddn(entry :: Entry.t(), dn :: binary()) :: Entry.t()
  def moddn(entry, dn) do
    %{entry | dn: dn}
  end

  @doc """
  Replaces the RDN of the entry, returning a new entry.
  
  """
  @spec modrdn(entry :: Entry.t(), rdn :: binary()) :: Entry.t()
  def modrdn(entry, rdn) do
    dn = DNUtils.replace_rdn(entry.dn, rdn)
    %{entry | dn: dn}
  end

  @doc """
  Deletes an attribute and all its values, returning a new entry
  
  """
  @spec delete(entry :: Entry.t(), attribute :: binary()) :: Entry.t()
  def delete(entry, attribute) do
    %{entry | attributes: Map.delete(entry.attributes, attribute)}
  end

  @doc """
  Deletes the specified value from an attribute, returning a new entry
  
  """
  @spec delete(entry :: Entry.t(), attribute :: binary(), value :: binary()) :: Entry.t()
  def delete(entry, attribute, value) do
    values = Map.get(entry.attributes, attribute, [])
             |> Enum.map(fn v -> if v == value, do: nil, else: v end)
             |> Enum.uniq()
             |> Enum.reject(&is_nil/1)

    %{entry | attributes: Map.put(entry.attributes, attribute, values)}
  end

  @doc """
  Replaces all the values of the specified attribute with the provided values, returning a new Entry.
  
  """
  @spec replace(entry :: Entry.t(), attribute :: binary(), values :: list()) :: Entry.t()
  def replace(entry, attribute, values) do
    %{entry | attributes: Map.put(entry.attributes, attribute, values)}
  end

  @doc """
  Replaces the old value the specified attribute with the new value, returning a new Entry.
  
  """
  @spec  replace(entry :: Entry.t(), attribute :: binary(), old_value :: binary(), new_value :: binary()) :: Entry.t()
  def replace(entry, attribute, old_value, new_value) do
    values = Map.get(entry.attributes, attribute, [])
             |> Enum.map(fn v -> if v == old_value, do: new_value, else: v end)
             |> Enum.reject(&is_nil/1)
             |> Enum.uniq()

    %{entry | attributes: Map.put(entry.attributes, attribute, values)}
  end

  @doc """
  Converts the entry into a simple map with atom keys.
    
  You may provide your own custom mapping for keys using the `:attr_map` option.
  
  """
  @spec to_map(entry :: Entry.t(), opts :: keyword()) :: map()
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
