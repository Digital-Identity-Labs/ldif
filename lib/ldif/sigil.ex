defmodule LDIF.Sigil do

  @moduledoc """
  `LDIF.Sigil` allows compile-time conversion of LDIF text into structs.
             
  The `~L` sigil will convert one or more LDIF records into structs. Modifiers allow the output to be adjusted. 
  
  Sigils can be convenient when testing and demonstrating software but in most cases it will be more practical to 
    load a separate LDIF file and process it with `LDIF.decode_entries!/2`
  
  Use `require LDIF.Sigil` to enable this in a module or function.
  """

  @doc """
  The `~L` sigil will convert one or more LDIF records into structs, defaulting to normal
    entry records. 
             
  ```elixir

   require LDIF.Sigil
  
   ~L\"\"\"
   dn:cn=Barbara Jensen, ou=Product Development, dc=airius, dc=com
   objectclass:top
   objectclass:person
   objectclass:organizationalPerson
   cn:Barbara Jensen
   cn:Barbara J Jensen
   cn:Babs Jensen
   sn:Jensen
   uid:bjensen
   telephonenumber:+1 408 555 1212
   description:Babs is a big sailing fan, and travels extensively in sea
     rch of perfect sailing conditions.
   title:Product Manager, Rod and Reel Division
   \"\"\"
   |> List.first()
   |> LDIF.Entry.attribute("cn")
   #=> ["Barbara Jensen", "Barbara J Jensen", "Babs Jensen"]
    ```
    You can adjust the output with modifiers:
  
    * `X` - allows external HTTP/HTTPS resources to be embedded *at compile time*
    * `m` - merges language-tagged attributes into a single untagged attribute
    * `n` - normalize each entry's DN (does not change DNs used in attributes)
    * `e` - specified that all records are normal entries (the default)
    * `c` - specifies that all records are special change entries

  ```elixir

   require LDIF.Sigil
  
   ~L\"\"\"
   dn: ou=Product Development, dc=airius, dc=com
  ou: Product Development
  objectClass: top
  objectClass: organizationalUnit
   \"\"\"n
   |> List.first()
   |> LDIF.Entry.dn()
   #=> "ou=product development,dc=airius,dc=com"
    ```
    
  """
  #@spec sigil_L(term :: binary(), modifiers :: charlist()) :: list()
  defmacro sigil_L(string, modifiers)
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
