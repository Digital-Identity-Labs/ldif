defmodule  LDIF.Import.Transform do
  @moduledoc false
  
  alias LDIF.DNUtils

  @spec attributes(attr_list :: list(), opts :: keyword()) :: list()
  def attributes(attr_list, opts \\ []) do
    attr_list
    |> Enum.reject(&is_nil/1)
    |> language_tags(opts[:lang_tags])
    |> reject_attrs(opts[:reject])
    |> redact_values(opts[:redact])
    |> normalize_dns(opts[:normalize_dns])
  end

  @spec entry(map :: map, opts :: keyword()) :: map()
  def entry(map, opts \\ []) do
    map
    |> single_values(opts[:single_value])
    |> Map.new()
  end

  #################################

  @spec language_tags(entry :: list(), bool :: boolean()) :: list()
  defp language_tags(entry, false) do
    entry
    |> Enum.map(fn {k, v} -> {List.first(String.split(k, ";")), v} end)
  end
  
  defp language_tags(entry, _)  do
    entry
  end

  @spec reject_attrs(entry :: list(), attr :: binary() | nil | list()) :: list()
  defp reject_attrs(entry, nowt) when is_nil(nowt) or nowt == [] do
    entry
  end
  
  defp reject_attrs(entry, attr) when is_binary(attr) do
    reject_attrs(entry, [attr])
  end
  
  defp reject_attrs(entry, attrs) do
    entry
    |> Enum.reject(fn {k, _v} -> k in attrs end)
  end

  @spec single_values(entry :: map(), attr :: binary() | nil | list()) :: list()
  defp single_values(entry, nowt) when is_nil(nowt) or nowt == [] do
    entry
  end

  defp single_values(entry, attr) when is_binary(attr) do
    single_values(entry, [attr])
  end

  defp single_values(entry, attrs) do
    entry
    |> Enum.map(fn {k, v} -> if k in attrs, do: {k, List.first(v)}, else: {k, v} end)
  end

  @spec redact_values(entry :: list(), attr :: binary() | nil | list()) :: list()
  defp redact_values(entry, nowt) when is_nil(nowt) or nowt == [] do
    entry
  end

  defp redact_values(entry, attr) when is_binary(attr) do
    redact_values(entry, [attr])
  end

  defp redact_values(entry, attrs) do
    entry
    |> Enum.map(fn {k, v} -> if k in attrs, do: {k, "********"}, else: {k, v} end)
  end

  @spec normalize_dns(entry :: list(), ctrl :: boolean() | list()) :: list()  
  defp normalize_dns(entry, true) do
    entry
    |> normalize_dns(["dn"])
  end

  defp normalize_dns(entry, dnattrs) when is_list(dnattrs) do
    entry
    |> Enum.map(fn {k, v} -> if k in dnattrs, do: {k, DNUtils.normalize_dn(v)}, else: {k, v} end)
  end

  defp normalize_dns(entry, _) do
    entry
  end
  
end
