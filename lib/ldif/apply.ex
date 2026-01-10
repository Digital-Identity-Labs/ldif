defmodule  LDIF.Apply do

  alias LDIF.Change
  alias LDIF.Entry
  alias LDIF.DNUtils

  def apply(change, %Entry{} = entry) when is_map(change)do
    List.wrap(Change.apply(change, entry))
  end

  def apply(changes, %Entry{} = entry) when is_list(changes)do
    Change.apply(changes, List.wrap(entry))
  end

  def apply(all_changes, all_entries) when is_list(all_changes) and is_list(all_entries) do

    changes_lookup = changes_lookup_map(all_changes)

    # Edits
    Enum.flat_map(
      all_entries,
      fn entry ->
        changes = Map.get(changes_lookup, entry.dn, [])
        if Enum.empty?(changes) do
          [entry]
        else
          Enum.reduce(changes, entry, fn
            change, nil -> nil
            change, entry -> List.wrap(Change.apply(change, entry))
          end)
          |> Apex.ap(label: "returned")
          |> Enum.reject(&is_nil/1)
          |> Apex.ap(label: "EH?")
        end
      end
    )

    # Adds

  end

  def filter(changes, entries) do

    dns = change_entry_intersection_dns(changes, entries)

    changes = changes
              |> Enum.filter(fn change -> change.dn in dns end)

    entries = entries
              |> Enum.filter(fn entry -> entry.dn in dns end)

    {changes, entries}

  end

  def changes_lookup_map(list) do
    list
    |> Enum.group_by(fn c -> c.dn end, fn c -> c end)
  end

  def entries_lookup_map(list) do
    list
    |> Enum.map(fn entry -> {entry.dn, entry} end)
    |> Map.new()
  end

  def change_entry_intersection_dns(changes, entries) do
    change_dns = MapSet.new(list_dns(changes))
    entry_dns = MapSet.new(list_dns(entries))
    MapSet.intersection(entry_dns, change_dns)
  end

  def list_dns(list) do
    list
    |> Enum.map(fn s -> DNUtils.normalize_dn(s.dn) end)
  end

end
