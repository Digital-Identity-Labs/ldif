defmodule LDIF.Filter do
  @moduledoc """
  A collection of simple filters that only return matching Entity structs from an enumerable.
  """

  @doc """
  Filter the enumerable to only include the specified objectclass
  
  Passing `false` as the final parameter will invert the filter, producing the opposite effect. 
  
  """
  @spec objectclass(enum :: Enumerable.t(), class :: binary(), bool :: boolean()) :: Enumerable.t()
  def objectclass(enum, class, bool \\ true) do
    enum
    |> Enum.filter(
         fn e ->
           (
             String.downcase("#{class}") in Enum.map(
               Map.get(e.attributes, "objectClass", nil) || Map.get(e.attributes, "objectclass", []),
               &String.downcase/1
             )) == bool end
       )
  end

  @doc """
  Filter the enumerable to only include the specified attribute (with any values)
  
  Passing `false` as the final parameter will invert the filter, producing the opposite effect. 
  
  """
  @spec attribute(enum :: Enumerable.t(), attr :: binary(), bool :: boolean()) :: Enumerable.t()
  def attribute(enum, attr, bool \\ true) do
    enum
    |> Enum.filter(
         fn e -> (is_nil(Map.get(e.attributes, attr, nil))) != bool end
       )
  end

  @doc """
  Filter the enumerable to only include the specified attribute if it contains the specified value
  
  Passing `false` as the final parameter will invert the filter, producing the opposite effect. 
  
  """
  @spec attribute_has(enum :: Enumerable.t(), attr :: binary(), value :: binary(), bool :: boolean()) :: Enumerable.t()
  def attribute_has(enum, attr, value, bool \\ true) do
    enum
    |> Enum.filter(
         fn e -> (value in Map.get(e.attributes, attr, [])) == bool end
       )
  end

  @doc """
  Only return entries that represent people.  
  
  Passing `false` as the final parameter will invert the filter, producing the opposite effect. 
  
  """
  @spec person(enum :: Enumerable.t(), bool :: boolean()) :: Enumerable.t()
  def person(enum, bool \\ true) do
    objectclass(enum, "person", bool)
  end

  @doc """
  Only return Change entries, not regular entries.
  
  Passing `false` as the final parameter will invert the filter, producing the opposite effect. 
  
  """
  @spec change(enum :: Enumerable.t(), bool :: boolean()) :: Enumerable.t()
  def change(enum, bool \\ true) do
    enum
    |> Enum.filter(
         fn e -> (is_struct(e, LDIF.Entry)) != bool end
       )
  end


end
