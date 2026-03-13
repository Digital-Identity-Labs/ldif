defmodule  LDIF.Import do

  alias LDIF.Import.Entries
  alias LDIF.Import.Changes

  @spec entries(ldif :: binary(), opts :: keyword()) :: %Stream{} | function()
  def entries(ldif, opts \\ []) do
    Entries.import(ldif, opts)
  end

  @spec changes(ldif :: binary(), opts :: keyword()) :: %Stream{} | function()
  def changes(ldif, opts \\ []) do
    Changes.import(ldif, opts)
  end

end
