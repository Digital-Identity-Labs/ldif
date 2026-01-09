defmodule  LDIF.Import.Changes do

  alias LDIF.Change
  alias LDIF.Import.Record
  alias LDIF.Import.Ingest
  alias LDIF.Import.Transform

  def import(ldif, opts) do
    ldif
    |> Record.stream()
    |> Stream.map(fn entry_text -> ingest(entry_text, opts) end)
    |> Stream.map(fn map -> Change.new(map["dn"], map) end)
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
                  [name, value] ->  Ingest.attribute(name, value, opts)
                end
              )
             #           |> transform_attrs(opts)
           |> join(opts)
           #           |> transform_entry(opts)
           #           |> normalize(opts)
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
  end

  def split_changes(items, opts) do
    items
    |> Enum.chunk_by(fn row -> row == ["-"] end)
    |> Enum.reject(fn row -> row == [["-"]] end)
  end

  def standalone_changes(changes, opts) do
    Apex.ap(changes, label: "Changes IN")

    [["dn", dn] | _] = List.first(changes)
    Enum.map(changes, fn change -> List.insert_at(change, 0, ["dn", dn]) end)
    |> Apex.ap(label: "Changes OUT")

  end

end
