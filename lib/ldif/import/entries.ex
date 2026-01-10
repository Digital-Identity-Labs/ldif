defmodule  LDIF.Import.Entries do

  alias LDIF.Entry
  alias LDIF.Import.Record
  alias LDIF.Import.Ingest
  alias LDIF.Import.Transform

  def import(ldif, opts) do
    ldif
    |> Record.stream()
    |> Stream.map(fn entry_text -> ingest(entry_text, opts) end)
    |> Stream.map(fn map -> Entry.new(map["dn"], map) end)
  end

  ###########################

  defp ingest(text, opts) do
    text
    |> Record.unfold(opts)
    |> Record.split(opts)
    |> Apex.ap()
    |> Enum.map(fn
      [name, value] -> Ingest.attribute(name, value, opts)
      other -> raise "Cannot parse line '#{other}' in LDIF!"
    end)
    |> Transform.attributes(opts)
    |> join(opts)
    |> Transform.entry(opts)
    |> normalize(opts)
  end

  defp join(map, opts) when is_map(map) do
    map
  end

  defp join(parts, opts) when is_list(parts) do

    Apex.ap(parts)

    map = parts
          |> Enum.reject(&is_nil/1)
          |> Enum.group_by(fn {n, v} -> n end, fn {n, v} -> v end)
    Map.put(map, "dn", List.first(Map.get(map, "dn")))
  end

  defp normalize(map, opts) when is_map(map)do
    map
  end

  defp normalize(list, opts) do
    Map.new(list)
  end


end
