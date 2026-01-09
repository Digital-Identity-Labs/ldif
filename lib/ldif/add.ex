defmodule LDIF.Add do
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
    changes = Map.delete(attributes, "dn") |> Map.delete("changetype")
    %Add{dn: dn, attributes: changes}
  end

end
