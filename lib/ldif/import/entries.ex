defmodule  LDIF.Import.Entries do
  @moduledoc false
  
  alias LDIF.Entry
  alias LDIF.Import.Record
  alias LDIF.Import.Ingest
  alias LDIF.Import.Transform

  @spec import(ldif ::binary(), opts :: keyword()) :: function() | %Stream{}  
  def import(ldif, opts \\ []) do
    ldif
    |> Record.stream()
    |> Stream.map(fn entry_text -> ingest(entry_text, opts) end)
    |> Stream.map(fn map -> Entry.new(map["dn"], map) end)
  end

  ###########################

  @spec ingest(text :: binary(), opts :: keyword()) :: map()
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
  end
  
  @spec join(parts :: list(), opts :: keyword())  :: map()
  defp join(parts, _opts) when is_list(parts) do

    map = parts
          |> Enum.reject(&is_nil/1)
          |> Enum.group_by(fn {n, _v} -> n end, fn {_n, v} -> v end)
    Map.put(map, "dn", List.first(Map.get(map, "dn")))
  end


end
