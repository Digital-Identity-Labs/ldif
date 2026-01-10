defmodule  LDIF.Utils do
  @moduledoc """
  Documentation for `Ldif`.
  """

  def normalize_dn(dn) do
   String.trim(dn)
   |> String.downcase()
   |> String.replace(" ", "", global: true)
  end

  def rdn(dn) do
    normalize_dn(dn)
    |> String.split(",")
    |> List.first()
  end

  def superior(dn) do
    String.replace_leading(normalize_dn(dn), "#{rdn(dn)},", "")
  end

  def ancestor_of?(dn1, dn2) do # ??
    String.starts_with?(normalize_dn(dn1), normalize_dn(dn2))
  end

  def descendent_of?(dn1, dn2) do # ??
    String.starts_with(normalize_dn(dn2), normalize_dn(dn1))
  end

end
