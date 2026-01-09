defmodule  LDIF.Import.Changes do

  alias LDIF.Add
  alias LDIF.Modify
  alias LDIF.Delete
  alias LDIF.ModDN
  alias LDIF.ModRDN
  alias LDIF.Import.Record
  alias LDIF.Import.Ingest
  alias LDIF.Import.Transform

  def import(ldif, opts) do
    ldif
    |> Record.stream()
    |> Stream.map(fn entry_text -> ingest(entry_text, opts) end)
    |> Stream.flat_map(fn changes -> Enum.map(changes, fn map -> to_struct(map["dn"], map) end) end)
  end

  def ingest(text, opts) do
    text
    |> Record.unfold(opts)
    |> Record.split(opts)
    |> split_changes(opts)
    |> standalone_changes(opts)
    |> Enum.map(
         fn changeset ->
           changeset
           |> Enum.map(
                fn
                  [name, value] -> Ingest.attribute(name, value, opts)
                end
              )
           |> Transform.attributes(opts)
           |> join(opts)
           |> Transform.entry(opts)
           |> normalize(opts)
         end
       )
  end

  def join(map, opts) when is_map(map) do
    map
  end

  def join(parts, opts) when is_list(parts) do

    map = parts
          |> Enum.reject(&is_nil/1)
          |> Enum.group_by(fn {n, v} -> n end, fn {n, v} -> v end)
    Map.put(map, "dn", List.first(Map.get(map, "dn")))
  end

  def normalize(map, opts) when is_map(map)do
    map
  end

  def normalize(list, opts) do
    Map.new(list)
    |> normalize(opts)
  end

  def split_changes(items, opts) do
    items
    |> Enum.chunk_by(fn row -> row == ["-"] end)
    |> Enum.reject(fn row -> row == [["-"]] end)
  end

  def standalone_changes(changes, opts) do
    [["dn", dn] | _] = List.first(changes)
    ["changetype", changetype] = Enum.find(List.first(changes), fn [k, v] -> k == "changetype"  end)
    Enum.map(changes, fn change -> List.insert_at(change, 0, ["dn", dn]) |> List.insert_at(1, ["changetype", changetype]) end)

  end

  def to_struct(dn, data) do
    type = List.first(data["changetype"])
    case type do
      "modify" -> Modify.new(dn, data)
      "delete" -> Delete.new(dn, data)
      "add" -> Add.new(dn, data)
      "modrdn" -> ModRDN.new(dn, data)
      "moddn" -> ModDN.new(dn, data)
      _ -> raise "Unknown LDIF change type '#{type}'!"
    end

  end

end
