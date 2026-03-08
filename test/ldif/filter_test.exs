defmodule FilterTest do
  use ExUnit.Case

  alias LDIF.Filter
  alias LDIF.Entry

  @entries File.read!("test/support/rfc_jensen_entries.ldif")
           |> LDIF.decode_entries!(ext_http: true, normalize_dns: true)

  @changes File.read!("test/support/rfc_jensen_changes.ldif")
           |> LDIF.decode_changes!(normalize_dns: true)

  describe "objectclass/1" do

    test "only returns entries that contain the specified objectclass" do
      assert [
               %Entry{dn: "ou=product development,dc=airius,dc=com"},
               %Entry{dn: "ou=pd accountants,ou=product development,dc=airius,dc=com"},
               %Entry{dn: "ou=accounting,dc=airius,dc=com"},
               %Entry{dn: "ou=product testing,dc=airius,dc=com"},
               %Entry{dn: "ou=営業部,o=airius"}
             ] = Filter.objectclass(@entries, "organizationalUnit")
    end

    test "also works with different capitalization" do
      assert [
               %Entry{dn: "ou=product development,dc=airius,dc=com"},
               %Entry{dn: "ou=pd accountants,ou=product development,dc=airius,dc=com"},
               %Entry{dn: "ou=accounting,dc=airius,dc=com"},
               %Entry{dn: "ou=product testing,dc=airius,dc=com"},
               %Entry{dn: "ou=営業部,o=airius"}
             ] = Filter.objectclass(@entries, "organizationalunit")
    end

    test "can be inverted by passing false as the last param" do
      assert [
               %Entry{dn: "cn=barbara jensen,ou=product development,dc=airius,dc=com"},
               %Entry{dn: "cn=bjorn jensen,ou=accounting,dc=airius,dc=com"},
               %Entry{dn: "cn=ingrid jensen,ou=product support,dc=airius,dc=com"},
               %Entry{dn: "cn=gern jensen,ou=product testing,dc=airius,dc=com"},
               %Entry{dn: "uid=rogasawara,ou=営業部,o=airius"},
               %Entry{dn: "cn=horatio jensen,ou=product testing,dc=airius,dc=com"}
             ] = Filter.objectclass(@entries, "organizationalunit", false)
    end

  end

  describe "attribute/1" do

    test "only returns entries that contain the specified attribute (with any value)" do
      assert [
               %Entry{dn: "uid=rogasawara,ou=営業部,o=airius"},
             ] = Filter.attribute(@entries, "mail")
    end

    test "can be inverted by passing false as the last param" do
      assert 10 = Enum.count(Filter.attribute(@entries, "mail", false))
    end

  end

  describe "attribute_has/1" do

    test "only returns entries that contain the specified attribute and value" do
      assert [
               %Entry{dn: "cn=bjorn jensen,ou=accounting,dc=airius,dc=com"},
             ] = Filter.attribute_has(@entries, "cn", "Bjorn Jensen")
    end

    test "can be inverted by passing false as the last param" do
      assert 10 = Enum.count(Filter.attribute_has(@entries, "cn", "Bjorn Jensen", false))
    end

  end

  describe "person/1" do

    test "only returns entries that are person records" do
      assert [
               %Entry{dn: "cn=barbara jensen,ou=product development,dc=airius,dc=com"},
               %Entry{dn: "cn=bjorn jensen,ou=accounting,dc=airius,dc=com"},
               %Entry{dn: "cn=ingrid jensen,ou=product support,dc=airius,dc=com"},
               %Entry{dn: "cn=gern jensen,ou=product testing,dc=airius,dc=com"},
               %Entry{dn: "uid=rogasawara,ou=営業部,o=airius"},
               %Entry{dn: "cn=horatio jensen,ou=product testing,dc=airius,dc=com"}
             ] = Filter.person(@entries)
    end

    test "can be inverted by passing false as the last param" do
      assert 5 = Enum.count(Filter.person(@entries, false))
    end

  end

  describe "change/1" do

    test "only returns records that are change records" do
      assert 0 = Enum.count(Filter.change(@entries))
      assert 11 = Enum.count(Filter.change(@changes))
    end

    test "can be inverted by passing false as the last param" do
      assert 11 = Enum.count(Filter.change(@entries, false))
      assert 0 = Enum.count(Filter.change(@changes, false))
    end

  end


end