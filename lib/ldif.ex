defmodule LDIF do
  @moduledoc """
  `LDIF` is a simple Elixir parser for [LDIF](https://www.rfc-editor.org/rfc/rfc2849)-formatted text files. 
  It will convert the entries within them to Elixir structs, and can directly apply LDIF change records to normal
  LDIF records.
 
  RFC 2849 describes LDIF as:

  > ... a file format suitable for describing
  > directory information or modifications made to directory information.
  > The file format, known as LDIF, for LDAP Data Interchange Format, is
  > typically used to import and export directory information between
  > LDAP-based directory servers, or to describe a set of changes which
  > are to be applied to a directory.

  The LDIF format is commonly used for importing records and changes into LDAP directories such as
  [OpenLDAP](https://www.openldap.org). Records are typically for contact details, user accounts, groups and
  departments but can be for any information.

  ## Features

  * Import normal LDAP directory entries from a string or a file, as a list of structs.
  * Import LDIF-formatted changes and apply to them to a list of entries
  * Supports including external data in entry attributes. Both file:// and https:// are supported but optional
  * A few utility functions are provided to directly modify entries - you can change DNs, adjust attribute values and
  so on.

  The top level `LDIF` module could contain all the functions you need but the following other modules may be of use:

  * `LDIF.Sigil` provides a sigil for importing LDIF data in documentation and tests
  * `LDIF.Entry` has various features for working with LDIF entries
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

  @doc """
  Decodes an LDIF string to a list of `LDIF.Entry` structs 
  
  Options to adjust the output include:
    * `:ext_files` - whether to allow external file: URLs to be fetched and embedded. Defaults to `true`
    * `:ext_http` - whether to allow external https: URLs to be fetched and embedded. Defaults to `false`
    * `:lang_tags` - whether to allow language-tagged attributes. Defaults to `true`
    * `:normalize_dns` - normalizes DNs if set to `true`. If given a list will normalize all listed attribute values. Defaults to `false`
    * `:redact` - a list of attributes to replace with `********`. 
    * `:reject` - a list of attributes to remove entirely
    * `:single_value` - a list of attributes to convert to a single value (the first one)
  
  """
  @spec decode_entries!(ldif :: binary(), opts :: keyword()) :: list()
  def decode_entries!(ldif, opts \\ []) do
    decode_entries_as_stream!(ldif, opts)
    |> Enum.to_list()
  end

  @doc """
  Decodes an LDIF string to a list of specific Change structs
  
  Options to adjust the output are the same as for `decode_entries!/2`
  
  """
  @spec decode_changes!(ldif :: binary(), opts :: keyword()) :: list()
  def decode_changes!(ldif, opts \\ []) do
    decode_changes_as_stream!(ldif, opts)
    |> Enum.to_list()
  end

  @doc """
  Decodes an LDIF string to a stream of `LDIF.Entry` structs 
  
  Options to adjust the output are the same as for `decode_entries!/2`
  
  """
  @spec decode_entries_as_stream!(ldif :: binary(), opts :: keyword()) :: %Stream{} | function()
  def decode_entries_as_stream!(ldif, opts \\ []) do
    Import.entries(ldif, Keyword.merge(@default_import_opts, opts))
  end

  @doc """
  Decodes an LDIF string to a stream of `LDIF.Entry` structs 
  
  Options to adjust the output are the same as for `decode_entries!/2`
  
  """
  @spec decode_changes_as_stream!(ldif :: binary(), opts :: keyword()) :: %Stream{} | function()
  def decode_changes_as_stream!(ldif, opts \\ []) do
    Import.changes(ldif, Keyword.merge(@default_import_opts, opts))
  end

  @doc """
  Applies the changes specified in a list of change entries to a list of normal entries. 
  
  """
  @spec apply_changes(changes :: list(), entries :: list()) :: list()
  def apply_changes(changes, entries) do
    Apply.apply_changes(changes, entries)
  end
  
end
