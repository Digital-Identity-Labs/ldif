defmodule  LDIF.Import.Ingest do

  def attribute("-", opts) do
    nil
  end

  def attribute("version", value, opts) do
    nil
  end

  def attribute(name, ":" <> value, opts) do
    decoded = String.trim(value)
              |> Base.decode64!()
    {name, decoded}
  end

  def attribute(name, "<" <> value, opts) do
    data = String.trim(value)
           |> String.replace_leading("file://", "")
           |> File.read!()
    {name, data}
  end

  def attribute(name, value, opts) do
    {name, value}
  end

end
