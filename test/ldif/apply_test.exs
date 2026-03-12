defmodule ApplyTest do
  use ExUnit.Case

  alias LDIF.Apply
  alias LDIF.Entry

  @delete_change LDIF.Delete.new(
                   "cn=Robert Jensen, ou=Marketing, dc=airius, dc=com",
                   %{
                     "changetype" => "delete"
                   }
                 )

  @entries File.read!("test/support/rfc_jensen_entries.ldif")
           |> LDIF.decode_entries!(ext_http: true, normalize_dns: true)

  @changes File.read!("test/support/rfc_jensen_changes.ldif")
           |> LDIF.decode_changes!(normalize_dns: true)

  describe "apply_changes/1" do

    test "applies a single change to an entry, and returns a list with zero or more entries" do
      assert [] = Apply.apply_changes(@delete_change, %Entry{dn: "cn=Robert Jensen, ou=Marketing, dc=airius, dc=com"})
    end

    test "applies a list of changes to an entry, and returns a list of entries" do
      assert [%Entry{dn: "cn=fiona jensen,ou=marketing,dc=airius,dc=com"}] = Apply.apply_changes(
               @changes,
               %Entry{dn: "cn=Robert Jensen, ou=Marketing, dc=airius, dc=com"}
             )
    end

    test "applies a list of changes to a list of entries, and returns a list of entries" do
      assert [
               %Entry{
                 dn: "cn=fiona jensen,ou=marketing,dc=airius,dc=com",
                 attributes: %{
                   "cn" => ["Fiona Jensen"],
                   "objectclass" => ["top", "person", "organizationalPerson"],
                   "sn" => ["Jensen"],
                   "telephonenumber" => ["+1 408 555 1212"],
                   "uid" => ["fiona"]
                 }
               },
               %Entry{
                 dn: "ou=Product Development Accountants, ou=Accounting, dc=airius, dc=com",
                 attributes: %{
                   "objectClass" => ["top", "organizationalUnit"],
                   "ou" => ["Product Development Accountants"]
                 }
               },
               %LDIF.Entry{
                 dn: "ou=pd accountants,ou=product development,dc=airius,dc=com",
                 attributes: %{
                   "objectClass" => ["top", "organizationalUnit"],
                   "ou" => ["Product Development Accountants"]
                 }
               },
               %Entry{
                 dn: "ou=accounting,dc=airius,dc=com",
                 attributes: %{
                   "objectClass" => ["top", "organizationalUnit"],
                   "ou" => ["Accounting"]
                 }
               },
               %Entry{
                 dn: "ou=product testing,dc=airius,dc=com",
                 attributes: %{
                   "objectClass" => ["top", "organizationalUnit"],
                   "ou" => ["Product Testing"]
                 }
               },
               %Entry{
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
               },
               %Entry{
                 dn: "cn=bjorn jensen,ou=accounting,dc=airius,dc=com",
                 attributes: %{
                   "cn" => ["Bjorn Jensen"],
                   "objectclass" => ["top", "person", "organizationalPerson"],
                   "sn" => ["Jensen"],
                   "telephonenumber" => ["+1 408 555 1212"]
                 }
               },
               %Entry{
                 dn: "cn=ingrid jensen,ou=product support,dc=airius,dc=com",
                 attributes: %{
                   "cn" => ["Ingrid Jensen"],
                   "objectclass" => ["top", "person", "organizationalPerson"],
                   "sn" => ["Jensen"],
                   "telephonenumber" => ["+1 408 555 1212"]
                 }
               },
               %Entry{
                 dn: "cn=gern jensen,ou=product testing,dc=airius,dc=com",
                 attributes: %{
                   "cn" => ["Gern Jensen", "Gern O Jensen"],
                   "description" => [
                     "What a careful reader you are!  This value is base-64-encoded because it has a control character in it (a CR).\r  By the way, you should really get out more."
                   ],
                   "objectclass" => ["top", "person", "organizationalPerson"],
                   "sn" => ["Jensen"],
                   "telephonenumber" => ["+1 408 555 1212"],
                   "uid" => ["gernj"]
                 }
               },
               %Entry{
                 dn: "ou=営業部,o=airius",
                 attributes: %{
                   "description" => ["Japanese office"],
                   "objectclass" => ["top", "organizationalUnit"],
                   "ou" => ["営業部"],
                   "ou;lang-en" => ["Sales"],
                   "ou;lang-ja" => ["営業部"],
                   "ou;lang-ja;phonetic" => ["えいぎょうぶ"]
                 }
               },
               %Entry{
                 dn: "uid=rogasawara,ou=営業部,o=airius",
                 attributes: %{
                   "cn" => ["小笠原 ロドニー"],
                   "cn;lang-en" => ["Rodney Ogasawara"],
                   "cn;lang-ja" => ["小笠原 ロドニー"],
                   "cn;lang-ja;phonetic" => ["おがさわら ろどにー"],
                   "givenname" => ["ロドニー"],
                   "givenname;lang-en" => ["Rodney"],
                   "givenname;lang-ja" => ["ロドニー"],
                   "givenname;lang-ja;phonetic" => ["ろどにー"],
                   "mail" => ["rogasawara@airius.co.jp"],
                   "objectclass" => ["top", "person", "organizationalPerson", "inetOrgPerson"],
                   "preferredlanguage" => ["ja"],
                   "sn" => ["小笠原"],
                   "sn;lang-en" => ["Ogasawara"],
                   "sn;lang-ja" => ["小笠原"],
                   "sn;lang-ja;phonetic" => ["おがさわら"],
                   "title" => ["営業部 部長"],
                   "title;lang-en" => ["Sales, Director"],
                   "title;lang-ja" => ["営業部 部長"],
                   "title;lang-ja;phonetic" => ["えいぎょうぶ ぶちょう"],
                   "uid" => ["rogasawara"],
                   "userpassword" => ["{SHA}O3HSv1MusyL4kTjP+HKI5uxuNoM="]
                 }
               },
               %Entry{
                 dn: "cn=horatio jensen,ou=product testing,dc=airius,dc=com",
                 attributes: %{
                   "cn" => ["Horatio Jensen", "Horatio N Jensen"],
                   "objectclass" => ["top", "person", "organizationalPerson"],
                   "sn" => ["Jensen"],
                   "telephonenumber" => ["+1 408 555 1212"],
                   "uid" => ["hjensen"]
                 }
               }
             ] = Apply.apply_changes(@changes, @entries)
    end

  end

  #######################################




end