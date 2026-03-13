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

  @spec decode_entries!(ldif :: binary(), opts :: keyword()) :: list()
  def decode_entries!(ldif, opts \\ []) do
    decode_entries_as_stream!(ldif, opts)
    |> Enum.to_list()
  end

  @spec decode_changes!(ldif :: binary(), opts :: keyword()) :: list()
  def decode_changes!(ldif, opts \\ []) do
    decode_changes_as_stream!(ldif, opts)
    |> Enum.to_list()
  end

  @spec decode_entries_as_stream!(ldif :: binary(), opts :: keyword()) :: %Stream{} | function()
  def decode_entries_as_stream!(ldif, opts \\ []) do
    Import.entries(ldif, Keyword.merge(@default_import_opts, opts))
  end

  @spec decode_changes_as_stream!(ldif :: binary(), opts :: keyword()) :: %Stream{} | function()
  def decode_changes_as_stream!(ldif, opts \\ []) do
    Import.changes(ldif, Keyword.merge(@default_import_opts, opts))
  end

  @spec apply_changes(changes :: list(), entries :: list()) :: list()
  def apply_changes(changes, entries) do
    Apply.apply_changes(changes, entries)
  end
  
end
