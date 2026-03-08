defmodule  LDIF.Import.Entries do

  alias LDIF.Entry
  alias LDIF.Import.Record
  alias LDIF.Import.Ingest
  alias LDIF.Import.Transform

  def import(ldif, opts \\ []) do
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
    |> Enum.map(fn
      [name, value] -> Ingest.attribute(name, value, opts)
      other -> raise "Cannot parse line '#{other}' in LDIF!"
    end)
    |> Transform.attributes(opts)
    |> join(opts)
    |> Transform.entry(opts)
    |> normalize(opts)
  end

  defp join(map, _opts) when is_map(map) do
    map
  end

  defp join(parts, _opts) when is_list(parts) do

    map = parts
          |> Enum.reject(&is_nil/1)
          |> Enum.group_by(fn {n, _v} -> n end, fn {_n, v} -> v end)
    Map.put(map, "dn", List.first(Map.get(map, "dn")))
  end

  defp normalize(map, _opts) when is_map(map)do
    map
  end

  defp normalize(list, _opts) do
    Map.new(list)
  end


end
