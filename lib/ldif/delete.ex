defmodule LDIF.Delete do
  @moduledoc false

  alias __MODULE__
  alias LDIF.DNUtils
  alias LDIF.Entry

  @type t :: %__MODULE__{
               dn: binary()
             }


  #@derive Jason.Encoder
  defstruct [
    dn: nil
  ]

  @spec new(dn :: binary(), attributes :: map()) :: struct()
  def new(dn, changes) do
    Map.delete(changes, "dn")
    |> Map.delete("changetype")
    %Delete{dn: dn}
  end

  @spec apply_to(change :: struct(), entry :: Entry.t() | nil) :: list(Entry.t())
  def apply_to(change, entry) do
    if DNUtils.normalize_dn(change.dn) == DNUtils.normalize_dn(entry.dn) do
      []
    else
      [entry]
    end
  end

  defimpl LDIF.Change, for: LDIF.Delete do
    def apply_to_entry(change, entry) do
      Delete.apply_to(change, entry)
    end
  end

end
