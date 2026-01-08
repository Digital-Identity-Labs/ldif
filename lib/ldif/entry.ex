defmodule LDIF.Entry do
  @moduledoc """
  Documentation for `Ldif`.
  """

  alias __MODULE__

  #@derive Jason.Encoder
  defstruct [
    dn: nil,
    type: :record,
    attributes: %{}
  ]

  def new(dn, attributes, type \\ :simple) do
    attributes = Map.delete(attributes, "dn")
    %Entry{dn: dn, attributes: attributes, type: type}
  end

end
