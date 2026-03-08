defmodule ImportTransformTest do
  use ExUnit.Case

  alias LDIF.Import.Transform

  @attributes [
    {"dn", "cn=Barbara Jensen, ou=Product Development, dc=airius, dc=com"},
    {"password", "secret"},
    {"cn", "Barbara Jensen"},
    {"cn;lang-en", "Babs Jensen"},
    {"objectclass", "top"},
    nil,
    {"objectclass", "person"},
    nil,
    {"objectclass", "organizationalPerson"}
  ]

  @entry %{
    "dn" => "cn=Barbara Jensen, ou=Product Development, dc=airius, dc=com",
    "password" => ["secret"],
    "cn" => ["Barbara Jensen", "Babs Jensen"],
    "objectclass" => ["top", "person", "organizationalPerson"]
  }

  describe "attributes/2" do

    test "removes nil values, leaving only attribute key-value tuples" do

      assert [
               {"dn", "cn=Barbara Jensen, ou=Product Development, dc=airius, dc=com"},
               {"password", "secret"},
               {"cn", "Barbara Jensen"},
               {"cn;lang-en", "Babs Jensen"},
               {"objectclass", "top"},
               {"objectclass", "person"},
               {"objectclass", "organizationalPerson"}
             ] = Transform.attributes(@attributes)

    end

    test "simplifies attributes with language tags if option is set to false" do
      assert [
               {"dn", "cn=Barbara Jensen, ou=Product Development, dc=airius, dc=com"},
               {"password", "secret"},
               {"cn", "Barbara Jensen"},
               {"cn", "Babs Jensen"},
               {"objectclass", "top"},
               {"objectclass", "person"},
               {"objectclass", "organizationalPerson"}
             ] = Transform.attributes(@attributes, lang_tags: false)

    end

    test "removes attributes if reject option is set" do
      assert [
               {"dn", "cn=Barbara Jensen, ou=Product Development, dc=airius, dc=com"},
               {"cn", "Barbara Jensen"},
               {"cn;lang-en", "Babs Jensen"},
               {"objectclass", "top"},
               {"objectclass", "person"},
               {"objectclass", "organizationalPerson"}
             ] = Transform.attributes(@attributes, reject: ["password"])

    end

    test "redacts attributes if option is set" do
      assert [
               {"dn", "cn=Barbara Jensen, ou=Product Development, dc=airius, dc=com"},
               {"password", "********"},
               {"cn", "Barbara Jensen"},
               {"cn;lang-en", "Babs Jensen"},
               {"objectclass", "top"},
               {"objectclass", "person"},
               {"objectclass", "organizationalPerson"}
             ] = Transform.attributes(@attributes, redact: ["password"])

    end

    test "normalises dn if option is set" do
      assert [
               {"dn", "cn=barbara jensen,ou=product development,dc=airius,dc=com"},
               {"password", "secret"},
               {"cn", "Barbara Jensen"},
               {"cn;lang-en", "Babs Jensen"},
               {"objectclass", "top"},
               {"objectclass", "person"},
               {"objectclass", "organizationalPerson"}
             ] = Transform.attributes(@attributes, normalize_dns: true)

    end

  end

  describe "entry/2" do

    test "converts the multivalue attributes in the single_value option to single values" do
      assert %{
               "cn" => "Barbara Jensen",
               "dn" => "cn=Barbara Jensen, ou=Product Development, dc=airius, dc=com",
               "objectclass" => ["top", "person", "organizationalPerson"],
               "password" => ["secret"]
             } = Transform.entry(@entry, single_value: ["cn"])
    end



  end

end