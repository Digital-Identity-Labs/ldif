defmodule ChangeTest do
  use ExUnit.Case

  alias LDIF.Entry
  alias LDIF.Change

  @add_change LDIF.Add.new(
                "cn=Fiona Jensen, ou=Marketing, dc=airius, dc=com",
                %{
                  "changetype" => "add",
                  "objectclass" => ["top", "person", "organizationalPerson"],
                  "cn" => ["Fiona Jensen"],
                  "sn" => ["Jensen"],
                  "uid" => ["fiona"],
                  "telephonenumber" => ["+1 408 555 1212"]
                }
              )

  @delete_change LDIF.Delete.new(
                   "cn=Robert Jensen, ou=Marketing, dc=airius, dc=com",
                   %{
                     "changetype" => "delete"
                   }
                 )

  @moddn_change   LDIF.ModDN.new(
                    "ou=PD Accountants, ou=Product Development, dc=airius, dc=com",
                    %{
                      "changetype" => ["modrdn"],
                      "newrdn" => ["ou=Product Development Accountants"],
                      "deleteoldrdn" => ["1"],
                      "newsuperior" => ["ou=Accounting, dc=airius, dc=com"]
                    }
                  )

  @mod_entry   LDIF.Entry.new(
                 "cn=Ingrid Jensen, ou=Product Support, dc=airius, dc=com",
                 %{
                   "objectclass" => ["top", "person", "organizationalPerson"],
                   "cn" => ["Ingrid Jensen"],
                   "sn" => ["Jensen"],
                   "telephonenumber" => ["+1 408 555 1212"],
                   "postaladdress" => ["1 Everystreet $ Manchester, UK"],
                   "description" => ["This is just here so we can delete it later"],
                   "facsimiletelephonenumber" => ["+1 408 555 9876", "+1 408 555 9877"]
                 }
               )

  @mod_change   LDIF.Modify.new(
                  "cn=Ingrid Jensen, ou=Product Support, dc=airius, dc=com",
                  %{
                    "changetype" => ["modify"],
                    "add" => ["postaladdress"],
                    "postaladdress" => ["123 Anystreet $ Sunnyvale, CA $ 94086"]
                  }
                )

  describe "apply/2" do

    test "LDIF.Add supports the protocol" do
      assert [
               %LDIF.Entry{
                 dn: "cn=Fiona Jensen, ou=Marketing, dc=airius, dc=com",
                 attributes: %{
                   "cn" => ["Fiona Jensen"],
                   "objectclass" => ["top", "person", "organizationalPerson"],
                   "sn" => ["Jensen"],
                   "telephonenumber" => ["+1 408 555 1212"],
                   "uid" => ["fiona"]
                 }
               }
             ] = Change.apply(@add_change, nil)
    end

    test "LDIF.Delete supports the protocol" do
      assert [] = Change.apply(@delete_change, %Entry{dn: "cn=Robert Jensen, ou=Marketing, dc=airius, dc=com"})
    end

    test "LDIF.ModDN supports the protocol" do
      assert [
               %LDIF.Entry{dn: "ou=Product Development Accountants, ou=Accounting, dc=airius, dc=com", attributes: %{}}
             ] = Change.apply(
               @moddn_change,
               %Entry{dn: "ou=PD Accountants, ou=Product Development, dc=airius, dc=com"}
             )
    end

    test "LDIF.Modify supports the protocol" do
      assert [
               %LDIF.Entry{
                 dn: "cn=Ingrid Jensen, ou=Product Support, dc=airius, dc=com",
                 attributes: %{
                   "cn" => ["Ingrid Jensen"],
                   "description" => ["This is just here so we can delete it later"],
                   "facsimiletelephonenumber" => ["+1 408 555 9876", "+1 408 555 9877"],
                   "objectclass" => ["top", "person", "organizationalPerson"],
                   "postaladdress" => ["1 Everystreet $ Manchester, UK", "123 Anystreet $ Sunnyvale, CA $ 94086"],
                   "sn" => ["Jensen"],
                   "telephonenumber" => ["+1 408 555 1212"]
                 }
               }
             ] = Change.apply(@mod_change, @mod_entry)
    end

  end

end