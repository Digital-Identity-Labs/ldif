defmodule  LDIF.DNUtils do
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

  def add_rdn(dn, rdn) do
    Enum.join([rdn, dn], ",") |> normalize_dn()
  end

  def replace_rdn(dn, rdn) do
    add_rdn(superior(dn), rdn)
  end

  def replace_superior(dn, sdn) do
    add_rdn(dn, rdn(sdn))
  end

  def ancestor_of?(dn1, dn2) do # ??
    String.starts_with?(normalize_dn(dn1), normalize_dn(dn2))
  end

  def descendent_of?(dn1, dn2) do # ??
    String.starts_with(normalize_dn(dn2), normalize_dn(dn1))
  end

end
