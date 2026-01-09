defmodule LDIF do
  @moduledoc """
  Documentation for `LDIF`.
  """

  alias LDIF.Entry
  alias LDIF.Import

  @default_import_opts [
    single_value: [],
    lang_tags: true,
    ext_files: true,
    ext_http: false,
    reject: [],
    http: []
  ]

  def entry(dn, attributes) do
    Entry.new(dn, attributes)
  end

  def change(dn, attributes) do
    Entry.new(dn, attributes)
  end

  def ldif_to_entries(ldif, opts \\ []) do
    Import.entries(ldif, Keyword.merge(@default_import_opts, opts))
  end

  def ldif_to_changes(ldif, opts \\ []) do
    Import.changes(ldif, Keyword.merge(@default_import_opts, opts))
  end

end
