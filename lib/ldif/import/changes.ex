defmodule  LDIF.Import.Changes do
  @moduledoc false
  
  alias LDIF.Add
  alias LDIF.Modify
  alias LDIF.Delete
  alias LDIF.ModDN
  alias LDIF.Import.Record
  alias LDIF.Import.Ingest
  alias LDIF.Import.Transform

  @spec import(ldif :: binary(), opts :: keyword()) :: function() | %Stream{}
  def import(ldif, opts \\ []) do
    ldif
    |> Record.stream()
    |> Stream.map(fn entry_text -> ingest(entry_text, opts) end)
    |> Stream.flat_map(fn changes -> Enum.map(changes, fn map -> to_struct(map["dn"], map) end) end)
  end

  ###############################

  @spec ingest(text:: binary(), opts :: keyword()) :: list()
  defp ingest(text, opts) do
    text
    |> Record.unfold(opts)
    |> Record.split(opts)
    |> split_changes(opts)
    |> standalone_changes(opts)
    |> Enum.map(
         fn changeset ->
           changeset
           |> Enum.map(fn
                   [name, value] -> Ingest.attribute(name, value, opts)
                   other -> raise "Cannot parse line '#{other}' in LDIF!" end)
           |> Transform.attributes(opts)
           |> join(opts)
           |> Transform.entry(opts)
         end
       )
  end
  
  @spec join(parts :: list(), opts :: keyword()) :: map()
  defp join(parts, _opts) when is_list(parts) do
    map = parts
          |> Enum.reject(&is_nil/1)
          |> Enum.group_by(fn {n, _v} -> n end, fn {_n, v} -> v end)
    Map.put(map, "dn", List.first(Map.get(map, "dn")))
  end

  @spec split_changes(items :: list(), opts :: keyword()) :: list()
  defp split_changes(items, _opts) do
    items
    |> Enum.chunk_by(fn row -> row == ["-"] end)
    |> Enum.reject(fn row -> row == [["-"]] end)
  end

  @spec standalone_changes(changes :: list(), opts :: keyword()) :: list()
  defp standalone_changes(changes, _opts) do
    [["dn", dn] | _] = List.first(changes)
    ["changetype", changetype] = Enum.find(List.first(changes), fn [k, _v] -> k == "changetype"  end)
    Enum.map(changes, fn change -> List.insert_at(change, 0, ["dn", dn]) |> List.insert_at(1, ["changetype", changetype]) end)

  end

  @spec to_struct(dn :: binary(), data :: map()) :: struct() 
  defp to_struct(dn, data) do
    type = List.first(data["changetype"])
    case type do
      "modify" -> Modify.new(dn, data)
      "delete" -> Delete.new(dn, data)
      "add" -> Add.new(dn, data)
      "modrdn" -> ModDN.new(dn, data)
      "moddn" -> ModDN.new(dn, data)
      _ -> raise "Unknown LDIF change type '#{type}'!"
    end

  end

end
