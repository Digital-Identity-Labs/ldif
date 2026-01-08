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

  def import(ldif, opts \\ @default_import_opts) do
    Import.import(ldif, opts)
  end

end
