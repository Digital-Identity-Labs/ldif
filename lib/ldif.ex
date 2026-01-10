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
    normalize_dns: false,
    http: []
  ]

  def entry(dn, attributes) do
    Entry.new(dn, attributes)
  end

  def change(dn, attributes) do
    Entry.new(dn, attributes)
  end

  def list_entries(ldif, opts \\ []) do
    stream_entries(ldif, opts)
    |> Enum.to_list()
  end

  def list_changes(ldif, opts \\ []) do
    stream_changes(ldif, opts)
    |> Enum.to_list()
  end

  def stream_entries(ldif, opts \\ []) do
    Import.entries(ldif, Keyword.merge(@default_import_opts, opts))
  end

  def stream_changes(ldif, opts \\ []) do
    Import.changes(ldif, Keyword.merge(@default_import_opts, opts))
  end

  def apply_changes(changes, entries) do
    []
  end

end
