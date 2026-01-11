defmodule LDIF.Export do

  alias LDIF.Export.Entries
  alias LDIF.Export.Changes

  def entries(entries, opts) do
    Entries.export(entries, opts)
  end

  def changes(changes, opts) do
    Changes.export(changes, opts)
  end

end
