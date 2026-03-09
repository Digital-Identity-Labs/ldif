defmodule LDIF.Sigil do
  
  defmacro sigil_L(term, modifiers)
  defmacro sigil_L({:<<>>, _meta, _pieces} = ldif_text, modifiers) do

    opts = modifiers_to_options(modifiers)

    cond do
      ?e in modifiers -> quote do
                           LDIF.decode_entries!(unquote(ldif_text), unquote(opts))
                         end
      ?c in modifiers -> quote do
                           LDIF.decode_changes!(unquote(ldif_text), unquote(opts))
                         end
      true -> quote do
                LDIF.decode_entries!(unquote(ldif_text), unquote(opts))
              end
    end
    
  end

  @spec modifiers_to_options(charlist()) :: keyword()
  defp modifiers_to_options(modifiers) do
    modifiers
    |> Enum.map(
         fn
           ?X -> {:ext_http, true}
           ?m -> {:lang_tags, false}
           ?n -> {:normalize_dns, true}
           ?e -> {:type, :entry}
           ?c -> {:type, :change}
           m -> raise ArgumentError, "Unknown sigil modifier #{<<?", m, ?">>}"
         end
       )
  end

end
