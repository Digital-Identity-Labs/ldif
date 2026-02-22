defmodule LDIF.Filter do

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

  def attribute(enum, attr, bool \\ true) do
    enum
    |> Enum.filter(
         fn e -> (is_nil(Map.get(e.attributes, attr, nil))) != bool end
       )
  end

  def attribute_has(enum, attr, value, bool \\ true) do
    enum
    |> Enum.filter(
         fn e -> (value in Map.get(e.attributes, attr, [])) == bool end
       )
  end

  def person(enum, bool \\ true) do
    objectclass(enum, "person", bool)
  end

  def change(enum, bool \\ true) do
    enum
    |> Enum.filter(
         fn e -> (is_struct(e, LDIF.Entry)) != bool end
       )
  end


end
