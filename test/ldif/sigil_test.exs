defmodule SigilTest do
  use ExUnit.Case

  doctest LDIF.Sigil
  
  alias LDIF.Entry

  import LDIF.Sigil

  describe "sigil_L/2" do

    test "by default, converts text into LDIF entry structs" do

      list = ~L"""
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

      assert %LDIF.Entry{
               dn: "cn=Barbara Jensen, ou=Product Development, dc=airius, dc=com",
               attributes: %{
                 "cn" => ["Barbara Jensen", "Barbara J Jensen", "Babs Jensen"],
                 "description" => [
                   "Babs is a big sailing fan, and travels extensively in search of perfect sailing conditions."
                 ],
                 "objectclass" => ["top", "person", "organizationalPerson"],
                 "sn" => ["Jensen"],
                 "telephonenumber" => ["+1 408 555 1212"],
                 "title" => ["Product Manager, Rod and Reel Division"],
                 "uid" => ["bjensen"]
               }
             } = List.first(list)

    end

    test "Normalizes DNs if passed the n modifier" do

      list = ~L"""
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
      """n

      assert %LDIF.Entry{
               dn: "cn=barbara jensen,ou=product development,dc=airius,dc=com",
               attributes: %{
                 "cn" => ["Barbara Jensen", "Barbara J Jensen", "Babs Jensen"],
                 "description" => [
                   "Babs is a big sailing fan, and travels extensively in search of perfect sailing conditions."
                 ],
                 "objectclass" => ["top", "person", "organizationalPerson"],
                 "sn" => ["Jensen"],
                 "telephonenumber" => ["+1 408 555 1212"],
                 "title" => ["Product Manager, Rod and Reel Division"],
                 "uid" => ["bjensen"]
               }
             } = List.first(list)

    end

    test "Allows HTTP/S calls if passed the X modifier" do

      list = ~L"""
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
      title:Product Manager, Rod and Reel Division
      description:< https://www.rfc-editor.org/info/rfc2849/
      """X

      assert %Entry{
               attributes: %{
                 "description" => ["<!DOCTYPE html" <> _]
               }
             } = List.first(list)

    end

    test "converts text into LDIF entry structs if given the e modifier" do

      list = ~L"""
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
      """e

      assert %LDIF.Entry{
               dn: "cn=Barbara Jensen, ou=Product Development, dc=airius, dc=com",
               attributes: %{
                 "cn" => ["Barbara Jensen", "Barbara J Jensen", "Babs Jensen"],
                 "description" => [
                   "Babs is a big sailing fan, and travels extensively in search of perfect sailing conditions."
                 ],
                 "objectclass" => ["top", "person", "organizationalPerson"],
                 "sn" => ["Jensen"],
                 "telephonenumber" => ["+1 408 555 1212"],
                 "title" => ["Product Manager, Rod and Reel Division"],
                 "uid" => ["bjensen"]
               }
             } = List.first(list)


    end

    test "converts text into LDIF change structs if given the c modifier" do

      list = ~L"""
      dn: cn=Ingrid Jensen, ou=Product Support, dc=airius, dc=com
      changetype: modify
      replace: postaladdress
      -
      delete: description
      -

      """c

      assert [
               %LDIF.Modify{
                 dn: "cn=Ingrid Jensen, ou=Product Support, dc=airius, dc=com",
                 modification: :replace,
                 attribute: "postaladdress",
                 values: nil
               },
               %LDIF.Modify{
                 dn: "cn=Ingrid Jensen, ou=Product Support, dc=airius, dc=com",
                 modification: :delete,
                 attribute: "description",
                 values: nil
               }
             ] = list


    end

  end

end