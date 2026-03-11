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

  def stream_entries!(ldif, opts \\ []) do
    Import.entries(ldif, Keyword.merge(@default_import_opts, opts))
  end

  def stream_changes!(ldif, opts \\ []) do
    Import.changes(ldif, Keyword.merge(@default_import_opts, opts))
  end

  def apply_changes(changes, entries) do
    Apply.apply_changes(changes, entries)
  end

  #  def entry(dn, attributes) do
  #    Entry.new(dn, attributes)
  #  end
  #
  #  def change(dn, :add, attributes) do
  #    Add.new(dn, attributes)
  #  end
  #
  #  def change(dn, :modify, attributes) do
  #    Modify.new(dn, attributes)
  #  end
  #
  #  def change(dn, :delete, attributes) do
  #    Delete.new(dn, attributes)
  #  end
  #
  #  def change(dn, :mod_dn, attributes) do
  #    ModDN.new(dn, attributes)
  #  end
  #
  #  def change(_, type, _) do
  #    raise "Unknown change type '#{type}'. Available change types are :add, :modify, :delete and :mod_dn"
  #  end
  
end
