defmodule  LDIF.Import.Record do

  @spec stream(records_text :: binary()) :: function() | %Stream{} 
  def stream(records_text) do
    records_text
    |> String.trim()
    |> String.splitter("\n\n", trim: true)
  end

  @spec unfold(record_text ::binary(), opts :: keyword()) :: binary()
  def unfold(record_text, _opts \\ []) do
    String.replace(record_text, ~r/(\n\s+)/, "", global: true)
  end

  @spec split(record_text ::binary(), opts :: keyword()) :: list()
  def split(record_text, _opts \\ []) do
    record_text
    |> String.trim()
    |> String.split("\n")
    |> Enum.reject(fn line -> String.starts_with?(line, "version:") end)
    |> Enum.reject(fn line -> String.starts_with?(line, "#") end)
    |> Enum.map(
         fn line ->
           String.split(line, ":", trim: false, parts: 2)
           |> Enum.map(&String.trim/1)
         end
       )
  end


end
