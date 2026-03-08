defmodule AttrMapperTest do
  use ExUnit.Case

  alias LDIF.AttrMapper

  @text """
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
  """
  @entry  LDIF.decode_entries!(@text)
          |> List.first()

  describe "entry_to_map/2" do

    test "converts an LDIF entry into a map" do
      assert %{} = AttrMapper.entry_to_map(@entry)
    end

    test "all keys in the map are atoms" do
      assert AttrMapper.entry_to_map(@entry)
             |> Map.keys()
             |> Enum.all?(&is_atom/1)
    end

    test "dn contains a single binary" do
      assert "cn=Barbara Jensen, ou=Product Development, dc=airius, dc=com" = AttrMapper.entry_to_map(@entry)[:dn]
    end

    test "the keys are correct snake_case equivalents, even when the casing on the LDAP field is wrong" do
      assert %{
               description: [
                 "Babs is a big sailing fan, and travels extensively in search of perfect sailing conditions."
               ],
               title: ["Product Manager, Rod and Reel Division"],
               cn: ["Barbara Jensen", "Barbara J Jensen", "Babs Jensen"],
               dn: "cn=Barbara Jensen, ou=Product Development, dc=airius, dc=com",
               object_class: ["top", "person", "organizationalPerson"],
               surname: ["Jensen"],
               telephone_number: ["+1 408 555 1212"],
               username: ["bjensen"]
             } = AttrMapper.entry_to_map(@entry)
    end

  end

end