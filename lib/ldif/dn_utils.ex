defmodule  LDIF.DNUtils do
  @moduledoc """
  Documentation for `Ldif`.
  """

  @spec normalize_dn(dn :: binary()) :: binary() 
  def normalize_dn(dn) do
    String.trim(dn)
    |> String.downcase()
    |> String.replace(~r/\s*,\s*/, ",", global: true)
    |> String.replace(~r/\s*=\s*/, "=", global: true)
  end

  @spec normalized?(dn :: binary()) :: boolean()
  def normalized?(dn) do
    cond do
      String.contains?(dn, ", ") -> false
      String.downcase(dn) != dn -> false
      true -> true
    end
  end

  @spec nrdn(dn :: binary()) :: binary()
  def nrdn(dn) do
    normalize_dn(dn)
    |> String.split(",")
    |> List.first()
  end

  @spec rdn(dn :: binary()) :: binary()
  def rdn(dn) do
    String.trim(dn)
    |> String.split(",")
    |> List.first()
  end

  @spec superior(dn :: binary()) :: binary()
  def superior(dn) do
    String.trim(dn)
    |> String.split(",", parts: 2)
    |> Enum.at(1)
    |> String.trim()
  end

  @spec add_rdn(dn :: binary(), rdn :: binary()) :: binary()
  def add_rdn(dn, rdn) do
    if normalized?(dn) do
      Enum.join([String.trim_trailing(rdn), String.trim_leading(dn)], ",")
    else
      Enum.join([String.trim_trailing(rdn), String.trim_leading(dn)], ", ")
    end
  end

  @spec replace_rdn(dn :: binary(), rdn :: binary()) :: binary()
  def replace_rdn(dn, rdn) do
    add_rdn(superior(dn), rdn)
  end

  @spec replace_superior(dn :: binary(), sdn :: binary()) :: binary()
  def replace_superior(dn, sdn) do
    if normalized?(dn) do
      add_rdn(sdn, nrdn(dn))
    else
      add_rdn(sdn, rdn(dn))
    end
  end

  @spec descendent_of?(dn1 :: binary(), dn2 :: binary()) :: boolean()
  def descendent_of?(dn1, dn2) do # ??
    String.ends_with?(normalize_dn(dn1), normalize_dn(dn2))
  end

  @spec ancestor_of?(dn1 :: binary(), dn2 :: binary()) :: boolean()
  def ancestor_of?(dn1, dn2) do # ??
    String.ends_with?(normalize_dn(dn2), normalize_dn(dn1))
  end

end
