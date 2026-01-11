defmodule  LDIF.Apply do

  alias LDIF.Change
  alias LDIF.Entry
  alias LDIF.DNUtils
  alias LDIF.Add

  def apply(change, %Entry{} = entry) when is_map(change)do
    List.wrap(Change.apply(change, entry))
  end

  def apply(changes, %Entry{} = entry) when is_list(changes)do
    Change.apply(changes, List.wrap(entry))
  end

  def apply(all_changes, all_entries) when is_list(all_changes) and is_list(all_entries) do
    apply_adds(all_changes, all_entries) ++ apply_edits(all_changes, all_entries)
  end

  def apply_adds(all_changes, all_entries) when is_list(all_changes) and is_list(all_entries) do

    entries_lookup = entries_lookup_map(all_entries)

    all_changes
    |> Enum.filter(fn change -> is_struct(change, Add) end)
    |> Enum.map(
         fn change ->
           if(
             entries_lookup[DNUtils.normalize_dn(change.dn)],
             do: raise("Record with DN #{change.dn} already exists, cannot be added!"),
             else: change
           )
         end
       )
    |> Enum.map(fn change -> Change.apply(change, nil) end)

  end

  def apply_edits(all_changes, all_entries) when is_list(all_changes) and is_list(all_entries) do

    changes_lookup = changes_lookup_map(all_changes)

    # Edits
    all_entries
    |> Enum.reject(fn entry -> is_struct(entry, Add) end)
    |> Enum.flat_map(
         fn entry ->
           changes = Map.get(changes_lookup, entry.dn, [])
           if Enum.empty?(changes) do
             [entry]
           else
             Enum.reduce(
               changes,
               entry,
               fn
                 change, nil -> nil
                 change, entry -> List.wrap(Change.apply(change, entry))
               end
             )
             |> Enum.reject(&is_nil/1)
           end
         end
       )
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
