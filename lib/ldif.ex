defmodule LDIF do
  @moduledoc """
  Documentation for `LDIF`.
  """
  
  alias LDIF.Import
  alias LDIF.Apply

  @default_import_opts [
    single_value: [],
    lang_tags: true,
    ext_files: true,
    ext_http: false,
    reject: [],
    redact: [],
    normalize_dns: false,
    http: [],
    one: false
  ]

  def decode_entries!(ldif, opts \\ []) do
    stream_entries!(ldif, opts)
    |> Enum.to_list()
  end

  def decode_changes!(ldif, opts \\ []) do
    stream_changes!(ldif, opts)
    |> Enum.to_list()
  end

  def decode_entries_as_stream!(ldif, opts \\ []) do
    Import.entries(ldif, Keyword.merge(@default_import_opts, opts))
  end

  def decode_changes_as_stream!(ldif, opts \\ []) do
    Import.changes(ldif, Keyword.merge(@default_import_opts, opts))
  end

  def apply_changes(changes, entries) do
    Apply.apply_changes(changes, entries)
  end
  
end
