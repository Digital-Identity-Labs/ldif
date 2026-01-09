defmodule LDIF.Entry do
  @moduledoc """
  Documentation for `Ldif`.
  """

  alias __MODULE__

  #@derive Jason.Encoder
  defstruct [
    dn: nil,
    attributes: %{}
  ]

  def new(dn, attributes) do
    attributes = Map.delete(attributes, "dn")
    %Entry{dn: dn, attributes: attributes}
  end

end
