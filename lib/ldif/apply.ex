defmodule  LDIF.Apply do

  @moduledoc false
  
  alias LDIF.Change
  alias LDIF.DNUtils
  alias LDIF.Add
  
  @spec apply_changes(all_changes :: list(), all_entries :: list()) :: list()
  def apply_changes(all_changes, all_entries) do
    
    all_changes = List.wrap(all_changes)
    all_entries = List.wrap(all_entries)
    
    apply_adds(all_changes, all_entries) ++ apply_edits(all_changes, all_entries)
    |> List.flatten()
  end

  ############################

  @spec apply_adds(all_changes :: list(), all_entries :: list()) :: list()
  defp apply_adds(all_changes, all_entries) when is_list(all_changes) and is_list(all_entries) do

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
    |> Enum.map(fn change -> Change.apply_to_entry(change, nil) end)
    |> List.flatten()
    |> Enum.reject(&is_nil/1)

  end

  @spec apply_edits(all_changes :: list(), all_entries :: list()) :: list()
  defp apply_edits(all_changes, all_entries) when is_list(all_changes) and is_list(all_entries) do

    changes_lookup = changes_lookup_map(all_changes)
    
    # Edits
    all_entries
    |> Enum.reject(fn entry -> is_struct(entry, Add) end)
    |> Enum.map(
         fn entry ->
           changes = Map.get(changes_lookup, DNUtils.normalize_dn(entry.dn), [])
           if Enum.empty?(changes) do
             [entry]
           else
             Enum.reduce(
               changes,
               entry,
               fn
                 _change, nil -> [nil]
                 change, [entry1, entry2] -> Change.apply_to_entry(change, entry1) ++ [entry2]
                 change, [entry] -> Change.apply_to_entry(change, entry)
                 _change, [] -> []
                 change, entry -> Change.apply_to_entry(change, entry)
               end)
             |> Enum.reject(&is_nil/1)
           end
         end
       )
  end

  @spec changes_lookup_map(list :: list()) :: list()
  defp changes_lookup_map(list) do
    list
    |> Enum.group_by(fn c -> DNUtils.normalize_dn(c.dn) end, fn c -> c end)
  end

  @spec changes_lookup_map(list :: list()) :: map()
  defp entries_lookup_map(list) do
    list
    |> Enum.map(fn entry -> {DNUtils.normalize_dn(entry.dn), entry} end)
    |> Map.new()
  end

end
