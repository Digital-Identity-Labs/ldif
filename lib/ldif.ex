defmodule LDIF do
  @moduledoc """
  Documentation for `LDIF`.
  """

  @default_import_opts [
    single_value: [],
    lang_tags: true,
    reject: []
  ]

  alias LDIF.Import

  def import_entries(ldif, opts \\ @default_import_opts) do
    Import.entries(ldif, opts)
  end

  def import_changes(ldif, opts \\ @default_import_opts) do
    Import.changes(ldif, opts)
  end

end
