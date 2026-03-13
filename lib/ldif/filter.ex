defmodule LDIF.Filter do

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

  @spec attribute(enum :: Enumerable.t(), attr :: binary(), bool :: boolean()) :: Enumerable.t()
  def attribute(enum, attr, bool \\ true) do
    enum
    |> Enum.filter(
         fn e -> (is_nil(Map.get(e.attributes, attr, nil))) != bool end
       )
  end

  @spec attribute_has(enum :: Enumerable.t(), attr :: binary(), value :: binary(), bool :: boolean()) :: Enumerable.t()
  def attribute_has(enum, attr, value, bool \\ true) do
    enum
    |> Enum.filter(
         fn e -> (value in Map.get(e.attributes, attr, [])) == bool end
       )
  end

  @spec person(enum :: Enumerable.t(), bool :: boolean()) :: Enumerable.t()
  def person(enum, bool \\ true) do
    objectclass(enum, "person", bool)
  end

  @spec change(enum :: Enumerable.t(), bool :: boolean()) :: Enumerable.t()
  def change(enum, bool \\ true) do
    enum
    |> Enum.filter(
         fn e -> (is_struct(e, LDIF.Entry)) != bool end
       )
  end


end
