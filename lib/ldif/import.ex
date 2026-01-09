defmodule  LDIF.Import do


  alias LDIF.Entry
  alias LDIF.Change
  alias LDIF.Import.Entries
  alias LDIF.Import.Changes

  def entries(ldif, opts) do
    Entries.import(ldif, opts)
  end

  def changes(ldif, opts) do
    Changes.import(ldif, opts)
  end

end
