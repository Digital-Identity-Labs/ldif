defmodule LdifTest do
  use ExUnit.Case

  alias LDIF.Entry

  doctest LDIF


  @entries_text File.read!("test/support/rfc_jensen_entries.ldif")
  @entries_structs LDIF.decode_entries!(@entries_text, ext_http: true, normalize_dns: true)

  @changes_test File.read!("test/support/rfc_jensen_changes.ldif")
  @changes_structs LDIF.decode_changes!(@changes_test, normalize_dns: true)

  @delete_change LDIF.Delete.new(
                   "cn=Robert Jensen, ou=Marketing, dc=airius, dc=com",
                   %{
                     "changetype" => "delete"
                   }
                 )

  describe "decode_entries!/2" do

    test "returns a list of entry structs when passed an LDIF string" do
      assert [
               %LDIF.Entry{
                 dn: "ou=Product Development, dc=airius, dc=com",
                 attributes: %{
                   "objectClass" => ["top", "organizationalUnit"],
                   "ou" => ["Product Development"]
                 }
               },
               %LDIF.Entry{
                 dn: "ou=PD Accountants, ou=Product Development, dc=airius, dc=com",
                 attributes: %{
                   "objectClass" => ["top", "organizationalUnit"],
                   "ou" => ["Product Development Accountants"]
                 }
               },
               %LDIF.Entry{
                 dn: "ou=Accounting, dc=airius, dc=com",
                 attributes: %{
                   "objectClass" => ["top", "organizationalUnit"],
                   "ou" => ["Accounting"]
                 }
               },
               %LDIF.Entry{
                 dn: "ou=Product Testing, dc=airius, dc=com",
                 attributes: %{
                   "objectClass" => ["top", "organizationalUnit"],
                   "ou" => ["Product Testing"]
                 }
               },
               %LDIF.Entry{
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
               },
               %LDIF.Entry{
                 dn: "cn=Bjorn Jensen, ou=Accounting, dc=airius, dc=com",
                 attributes: %{
                   "cn" => ["Bjorn Jensen"],
                   "objectclass" => ["top", "person", "organizationalPerson"],
                   "sn" => ["Jensen"],
                   "telephonenumber" => ["+1 408 555 1212"]
                 }
               },
               %LDIF.Entry{
                 dn: "cn=Ingrid Jensen, ou=Product Support, dc=airius, dc=com",
                 attributes: %{
                   "cn" => ["Ingrid Jensen"],
                   "description" => ["This is just here so we can delete it later"],
                   "objectclass" => ["top", "person", "organizationalPerson"],
                   "sn" => ["Jensen"],
                   "telephonenumber" => ["+1 408 555 1212"]
                 }
               },
               %LDIF.Entry{
                 dn: "cn=Gern Jensen, ou=Product Testing, dc=airius, dc=com",
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
               %LDIF.Entry{
                 dn: "ou=営業部,o=Airius",
                 attributes: %{
                   "description" => ["Japanese office"],
                   "objectclass" => ["top", "organizationalUnit"],
                   "ou" => ["営業部"],
                   "ou;lang-en" => ["Sales"],
                   "ou;lang-ja" => ["営業部"],
                   "ou;lang-ja;phonetic" => ["えいぎょうぶ"]
                 }
               },
               %LDIF.Entry{
                 dn: "uid=rogasawara,ou=営業部,o=Airius",
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
               %LDIF.Entry{
                 dn: "cn=Horatio Jensen, ou=Product Testing, dc=airius, dc=com",
                 attributes: %{
                   "cn" => ["Horatio Jensen", "Horatio N Jensen"],
                   "objectclass" => ["top", "person", "organizationalPerson"],
                   "sn" => ["Jensen"],
                   "telephonenumber" => ["+1 408 555 1212"],
                   "uid" => ["hjensen"]
                 }
               }
             ] = LDIF.decode_entries!(@entries_text)
    end

  end

  describe "decode_changes!/2" do

    test "returns a list of change structs when passed an LDIF string" do
      assert [
               %LDIF.Add{
                 dn: "cn=Fiona Jensen, ou=Marketing, dc=airius, dc=com",
                 attributes: %{
                   "cn" => ["Fiona Jensen"],
                   "objectclass" => ["top", "person", "organizationalPerson"],
                   "sn" => ["Jensen"],
                   "telephonenumber" => ["+1 408 555 1212"],
                   "uid" => ["fiona"]
                 }
               },
               %LDIF.Delete{dn: "cn=Robert Jensen, ou=Marketing, dc=airius, dc=com"},
               %LDIF.ModDN{
                 dn: "cn=Paul Jensen, ou=Product Development, dc=airius, dc=com",
                 deleteoldrdn: true,
                 newsuperior: nil,
                 newrdn: "cn=Paula Jensen"
               },
               %LDIF.ModDN{
                 dn: "ou=PD Accountants, ou=Product Development, dc=airius, dc=com",
                 deleteoldrdn: false,
                 newsuperior: "ou=Accounting, dc=airius, dc=com",
                 newrdn: "ou=Product Development Accountants"
               },
               %LDIF.Modify{
                 dn: "cn=Paula Jensen, ou=Product Development, dc=airius, dc=com",
                 modification: :add,
                 attribute: "postaladdress",
                 values: ["123 Anystreet $ Sunnyvale, CA $ 94086"]
               },
               %LDIF.Modify{
                 dn: "cn=Paula Jensen, ou=Product Development, dc=airius, dc=com",
                 modification: :delete,
                 attribute: "description",
                 values: nil
               },
               %LDIF.Modify{
                 dn: "cn=Paula Jensen, ou=Product Development, dc=airius, dc=com",
                 modification: :replace,
                 attribute: "telephonenumber",
                 values: ["+1 408 555 1234", "+1 408 555 5678"]
               },
               %LDIF.Modify{
                 dn: "cn=Paula Jensen, ou=Product Development, dc=airius, dc=com",
                 modification: :delete,
                 attribute: "facsimiletelephonenumber",
                 values: ["+1 408 555 9876"]
               },
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
               },
               %LDIF.Delete{dn: "ou=Product Development, dc=airius, dc=com"}
             ] = LDIF.decode_changes!(@changes_test)
    end

  end

  describe "decode_entries_as_stream!/2" do

    test "returns a stream of entry structs when passed an LDIF string" do
      output = LDIF.decode_entries_as_stream!(@entries_text)
      assert is_function(output) or is_struct(output, Stream)
    end

    test "they are the right structs aren't they?" do
      assert [
               %LDIF.Entry{
                 dn: "ou=Product Development, dc=airius, dc=com",
                 attributes: %{
                   "objectClass" => ["top", "organizationalUnit"],
                   "ou" => ["Product Development"]
                 }
               }
             ] = LDIF.decode_entries_as_stream!(@entries_text)
                 |> Enum.take(1)
    end

  end

  describe "decode_changes_as_stream!/2" do

    test "returns a stream of change structs when passed an LDIF string" do
      output = LDIF.decode_changes_as_stream!(@changes_test)
      assert is_function(output) or is_struct(output, Stream)
    end

    test "they are the right structs aren't they?" do
      assert [
               %LDIF.Add{
                 dn: "cn=Fiona Jensen, ou=Marketing, dc=airius, dc=com",
                 attributes: %{
                   "cn" => ["Fiona Jensen"],
                   "objectclass" => ["top", "person", "organizationalPerson"],
                   "sn" => ["Jensen"],
                   "telephonenumber" => ["+1 408 555 1212"],
                   "uid" => ["fiona"]
                 }
               }
             ] = LDIF.decode_changes_as_stream!(@changes_test)
                 |> Enum.take(1)
    end

  end

  describe "apply_changes!/2" do

    test "returns a list of changed entry structs when passed a single entry and change" do
      assert [] = LDIF.apply_changes(@delete_change, %Entry{dn: "cn=Robert Jensen, ou=Marketing, dc=airius, dc=com"})
    end

    test "returns a list of changed entry structs when passed a single entry and a list of changes" do
      assert [
               %LDIF.Entry{
                 dn: "cn=fiona jensen,ou=marketing,dc=airius,dc=com",
                 attributes: %{
                   "cn" => ["Fiona Jensen"],
                   "objectclass" => ["top", "person", "organizationalPerson"],
                   "sn" => ["Jensen"],
                   "telephonenumber" => ["+1 408 555 1212"],
                   "uid" => ["fiona"]
                 }
               }
             ] = LDIF.apply_changes(@changes_structs, %Entry{dn: "cn=Robert Jensen, ou=Marketing, dc=airius, dc=com"})
    end

    test "returns a list of changed entry structs when passed a list of entries and a list of changes" do

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
             ] = LDIF.apply_changes(@changes_structs, @entries_structs)

    end

  end


end
