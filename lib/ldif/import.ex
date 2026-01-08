defmodule  LDIF.Import do

  #@splitter :binary.compile_pattern(["\n" <>_, "\n\n"])

  alias LDIF.Entry

  def import(ldif, opts) do
    ldif
    |> String.splitter("\n\n", trim: true)
    |> Stream.map(fn entry_text -> ingest_entry(entry_text, opts) end)
    |> Stream.map(fn map -> Entry.new(map["dn"], map) end)
  end

  def ingest_entry(text, opts) do
    text
    |> unfold_entry(opts)
    |> split_entry(opts)
    |> Enum.map(fn
               [name, value] -> ingest_line(name, value, opts)
               [name] -> ingest_line(name, opts) end)
    |> transform_attrs(opts)
    |> join_entry(opts)
    |> transform_entry(opts)
    |> normalize_entry(opts)
  end

  def ingest_line("-", opts) do
    nil
  end

  def ingest_line("version", value, opts) do
    nil
  end

  def ingest_line(name, ":" <> value, opts) do
    decoded = String.trim(value)
              |> Base.decode64!()
    {name, decoded}
  end

  def ingest_line(name, "<" <> value, opts) do
    data = String.trim(value)
           |> String.replace_leading("file://", "")
           |> File.read!()
    {name, data}
  end

  def ingest_line(name, value, opts) do
    {name, value}
  end

  def unfold_entry(entry_text, opts) do
    String.replace(entry_text, ~r/(\n\s+)/, "", global: true)
  end

  def join_entry(map, opts) when is_map(map) do
    map
  end

  def join_entry(parts, opts) when is_list(parts) do
    map = parts
          |> Enum.reject(&is_nil/1)
          |> Enum.group_by(fn {n, v} -> n end, fn {n, v} -> v end)
    Map.put(map, "dn", List.first(Map.get(map, "dn")))
  end

  def normalize_entry(map, opts) when is_map(map)do
    map
  end

  def normalize_entry(list, opts) do
    Map.new(list)
  end

  def transform_attrs(map, opts) do
    map
    |> language_tags(opts[:lang_tags])
    |> reject_attrs(opts[:reject])
    |> redact_values(opts[:redact])
  end

  def transform_entry(map, opts) do
    map
    |> single_values(opts[:single_value])
  end

  def language_tags(entry, false) do
    entry
    |> Enum.map(fn {k, v} -> {List.first(String.split(k, ";")), v} end)
  end

  def language_tags(entry, _)  do
    entry
  end

  def reject_attrs(entry, nowt) when is_nil(nowt) or nowt == [] do
    entry
  end

  def reject_attrs(entry, attr) when is_binary(attr) do
    reject_attrs(entry, [attr])
  end

  def reject_attrs(entry, attrs) do
    entry
    |> Enum.reject(fn {k, v} -> k in attrs end)
  end

  def single_values(entry, nowt) when is_nil(nowt) or nowt == [] do
    entry
  end

  def single_values(entry, attr) when is_binary(attr) do
    single_values(entry, [attr])
  end

  def single_values(entry, attrs) do
    entry
    |> Enum.map(fn {k, v} -> if k in attrs, do: {k, List.first(v)}, else: {k, v} end)
  end

  def redact_values(entry, nowt) when is_nil(nowt) or nowt == [] do
    entry
  end

  def redact_values(entry, attr) when is_binary(attr) do
    redact_values(entry, [attr])
  end

  def redact_values(entry, attrs) do
    entry
    |> Enum.map(fn {k, v} -> if k in attrs, do: {k, "********"}, else: {k, v} end)
  end

  def split_entry(entry_text, opts) do
    entry_text
    |> String.trim()
    |> String.split("\n")
    |> Enum.reject(fn line -> String.starts_with?(line, "#") end)
    |> Enum.map(
         fn line ->
           String.split(line, ":", trim: false, parts: 2)
           |> Enum.map(&String.trim/1)
         end
       )
  end

end
