defmodule  LDIF.Import.Ingest do
  @moduledoc false
  
  
  @spec attribute(name :: binary(), opts :: keyword()) :: nil
  def attribute("-", _opts) do
    nil
  end

  @spec attribute(name :: binary(), value :: binary(), opts :: keyword()) :: nil | tuple()
  def attribute("version", _value, _opts) do
    nil
  end

  def attribute(name, ":" <> value, _opts) do
    decoded = String.trim(value)
              |> Base.decode64!()
    {name, decoded}
  end

  def attribute(name, "<" <> value, opts) do
    data = String.trim(value)
           |> read_external(opts)
    {name, data}
  end

  def attribute(name, value, _opts) do
    {name, value}
  end

  @spec read_external(url :: binary(), opts :: keyword()) :: binary()
  defp read_external("file:" <> _ = value, opts) do
    if opts[:ext_files] == true do
      String.replace_leading(value, "file://", "")
      |> File.read!()
    else
      raise "LDIF specified an external file #{value} but loading files has been disabled"
    end
  end

  defp read_external("http" <> _ = value, opts) do
    if opts[:ext_http] == true do
      Req.get!(value).body
      Req.new(http_options(opts[:http] || []))
      |> CurlReq.Plugin.attach()
      |> Req.get!(url: value)
      |> Map.get(:body)
    else
      raise "LDIF specified an HTTP file #{value} but HTTP has been disabled"
    end
  end

  defp read_external(value, _opts) do
    raise "LDIF specified an remote file using an unsupported URI scheme: #{value}"
  end

  @spec http_options(extra_options :: keyword()) :: keyword()
  defp http_options(extra_options) do
    Keyword.merge(
      [
        headers: %{
          "accept-charset" => "utf-8"
        },
        max_redirects: 3,
        cache: true,
        cache_dir: Application.get_env(:ldif, :cache_dir, :filename.basedir(:user_cache, "ldif")),
        user_agent: "LDIF #{Application.spec(:ldif, :vsn)}",
        http_errors: :raise,
        max_retries: 3,
        retry_delay: &retry_jitter/1
      ],
      extra_options
    )
  end

  @spec retry_jitter(n :: integer()) :: integer()
  defp retry_jitter(n) do
    trunc(Integer.pow(2, n) * 1000 * (1 - 0.1 * :rand.uniform()))
  end

end
