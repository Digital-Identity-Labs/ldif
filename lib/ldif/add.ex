defmodule LDIF.Add do
  @moduledoc false

  alias __MODULE__
  alias LDIF.Entry

  @type t :: %__MODULE__{
               dn: binary(),
               attributes: map()
             }

  #@derive Jason.Encoder
  defstruct [
    dn: nil,
    attributes: %{}
  ]

  @spec new(dn :: binary(), attributes :: map()) :: struct()
  def new(dn, attributes) do
    changes = Map.delete(attributes, "dn")
              |> Map.delete("changetype")
    %Add{dn: dn, attributes: changes}
  end

  @spec apply_to(change :: struct(), entry :: %Entry{} | nil) :: list(%Entry{})
  def apply_to(change, nil) do
    [Entry.new(change.dn, change.attributes)]
  end

  def apply_to(change, entry) do
    Add.apply_to(change, nil) ++ [entry]
  end

  defimpl LDIF.Change, for: LDIF.Add do
    def apply_to_entry(change, entry) do
      Add.apply_to(change, entry)
    end
  end

end
