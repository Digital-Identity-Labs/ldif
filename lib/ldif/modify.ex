defmodule LDIF.Modify do
  @moduledoc """
  Documentation for `Ldif`.
  """

  alias __MODULE__

  @changetypes
  @modifications ["replace", "add", "delete"]

  #@derive Jason.Encoder
  defstruct [
    dn: nil,
    modification: nil,
    attribute: nil,
    values: %{}
  ]

  def new(dn, changes) do
    changes = Map.delete(changes, "dn") |> Map.delete("changetype")
    {modification, [attribute | _]} = Enum.find(changes, fn {k, v} -> k in @modifications end)
    values = Map.get(changes, attribute, nil)
    %Modify{dn: dn, modification: String.to_atom(modification), attribute: attribute, values: values}
  end

end
