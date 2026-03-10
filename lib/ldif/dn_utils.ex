defmodule  LDIF.DNUtils do
  @moduledoc """
  Documentation for `Ldif`.
  """

  def normalize_dn(dn) do
    String.trim(dn)
    |> String.downcase()
    |> String.replace(~r/\s*,\s*/, ",", global: true)
    |> String.replace(~r/\s*=\s*/, "=", global: true)
  end

  def normalized?(dn) do
    cond do
      String.contains?(dn, ", ") -> false
      String.downcase(dn) != dn -> false
      true -> true
    end
  end

  def nrdn(dn) do
    normalize_dn(dn)
    |> String.split(",")
    |> List.first()
  end

  def rdn(dn) do
    String.trim(dn)
    |> String.split(",")
    |> List.first()
  end

  def superior(dn) do
    String.trim(dn)
    |> String.split(",", parts: 2)
    |> Enum.at(1)
    |> String.trim()
  end

  def add_rdn(dn, rdn) do
    if normalized?(dn) do
      Enum.join([String.trim_trailing(rdn), String.trim_leading(dn)], ",")
    else
      Enum.join([String.trim_trailing(rdn), String.trim_leading(dn)], ", ")
    end
  end

  def replace_rdn(dn, rdn) do
    add_rdn(superior(dn), rdn)
  end

  def replace_superior(dn, sdn) do
    if normalized?(dn) do
      add_rdn(sdn, nrdn(dn))
    else
      add_rdn(sdn, rdn(dn))
    end
  end

  def descendent_of?(dn1, dn2) do # ??
    String.ends_with?(normalize_dn(dn1), normalize_dn(dn2))
  end

  def ancestor_of?(dn1, dn2) do # ??
    String.ends_with?(normalize_dn(dn2), normalize_dn(dn1))
  end

end
