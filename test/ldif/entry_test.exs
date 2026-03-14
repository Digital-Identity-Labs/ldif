defmodule EntryTest do
  use ExUnit.Case

  doctest LDIF.Entry
  
  alias LDIF.Entry

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


  describe "new/2" do

    test "can be created by passing a DN" do
      assert %Entry{dn: "cn=Barbara Jensen, ou=Product Development, dc=airius, dc=com", attributes: %{}} =
               Entry.new("cn=Barbara Jensen, ou=Product Development, dc=airius, dc=com")
    end

    test "can be passed a simple binary-keyed map for attributes" do
      assert %Entry{
               dn: "cn=Barbara Jensen, ou=Product Development, dc=airius, dc=com",
               attributes: %{
                 "ou" => ["top", "person"],
                 "cn" => ["Barbara Jensen"]
               }
             } =
               Entry.new(
                 "cn=Barbara Jensen, ou=Product Development, dc=airius, dc=com",
                 %{
                   "ou" => ["top", "person"],
                   "cn" => ["Barbara Jensen"]
                 }
               )
    end

  end

  describe "dn/1" do

    test "returns the DN of the entry" do
      assert "cn=Barbara Jensen, ou=Product Development, dc=airius, dc=com" = Entry.dn(@entry)
    end

  end

  describe "ndn/1" do
    test "returns a normalized version of the DN of the entry" do
      assert "cn=barbara jensen,ou=product development,dc=airius,dc=com" = Entry.ndn(@entry)
    end
  end

  describe "rdn/1" do
    test "returns the RDN of the entry" do
      assert "cn=Barbara Jensen" = Entry.rdn(@entry)
    end
  end

  describe "nrdn/1" do
    test "returns the normalized RDN of the entry" do
      assert "cn=barbara jensen" = Entry.nrdn(@entry)
    end
  end

  describe "superior/1" do
    test "returns the superior DN of the entry" do
      assert "ou=Product Development, dc=airius, dc=com" = Entry.superior(@entry)
    end
  end

  describe "attributes/1" do
    test "returns the attribute map for the entry" do
      assert %{
               "cn" => ["Barbara Jensen", "Barbara J Jensen", "Babs Jensen"],
               "description" => [
                 "Babs is a big sailing fan, and travels extensively in search of perfect sailing conditions."
               ],
               "objectclass" => ["top", "person", "organizationalPerson"],
               "sn" => ["Jensen"],
               "telephonenumber" => ["+1 408 555 1212"],
               "title" => ["Product Manager, Rod and Reel Division"],
               "uid" => ["bjensen"]
             } = Entry.attributes(@entry)
    end
  end

  describe "attribute/2" do
    test "returns the values of the specified attribute, or an empty list" do
      assert ["top", "person", "organizationalPerson"] = Entry.attribute(@entry, "objectclass")
      assert [] = Entry.attribute(@entry, "password")
    end
  end

  describe "get/2" do
    test "returns the values of the specified attribute, or nil" do
      assert ["top", "person", "organizationalPerson"] = Entry.get(@entry, "objectclass")
      assert is_nil(Entry.get(@entry, "password"))
    end
  end

  describe "merge_tagged/1" do

    test "merges together tagged attributes, stripping off the tags" do
      text = """
      dn:: b3U95Za25qWt6YOoLG89QWlyaXVz
      objectclass: top
      objectclass: organizationalUnit
      ou:: 5Za25qWt6YOo
      ou;lang-ja:: 5Za25qWt6YOo
      ou;lang-ja;phonetic:: 44GI44GE44GO44KH44GG44G2
      ou;lang-en: Sales
      description: Japanese office
      """
      entry = LDIF.decode_entries!(text)
              |> List.first()

      assert %Entry{
               dn: "ou=営業部,o=Airius",
               attributes: %{
                 "description" => ["Japanese office"],
                 "objectclass" => ["top", "organizationalUnit"],
                 "ou" => ["営業部", "Sales", "えいぎょうぶ"]
               }
             } = Entry.merge_tagged(entry)

    end

  end

  describe "add/3" do

    test "adds a value to the named attribute" do
      assert %Entry{
               attributes: %{
                 "objectclass" => ["top", "person", "organizationalPerson", "testPerson"]
               }
             } = Entry.add(@entry, "objectclass", "testPerson")
    end

    test "creates the attribute if it does not already exist" do
      assert %Entry{
               attributes: %{
                 "testStatus" => ["good"]
               }
             } = Entry.add(@entry, "testStatus", "good")
    end

  end

  describe "moddn/2" do

    test "changes the DN of the entry" do
      assert %Entry{
               dn: "cn=Barbara Example Jensen, ou=Product Development, dc=airius, dc=com"
             } = Entry.moddn(@entry, "cn=Barbara Example Jensen, ou=Product Development, dc=airius, dc=com")
    end

  end

  describe "modrdn/2" do

    test "changes the RDN of the entry" do
      assert %Entry{
               dn: "cn=Babs Example Jensen, ou=Product Development, dc=airius, dc=com"
             } = Entry.modrdn(@entry, "cn=Babs Example Jensen")
    end

  end

  describe "delete/2" do

    test "deletes an attribute completely" do
      assert [
               "cn",
               "description",
               "objectclass",
               "sn",
               "title",
               "uid"
             ] = Map.get(
                   Entry.delete(@entry, "telephonenumber"),
                   :attributes
                 )
                 |> Map.keys()
    end

  end

  describe "delete/3" do

    test "deletes one value from an attribute" do
      assert ["top", "person"] = Entry.delete(@entry, "objectclass", "organizationalPerson")
                                 |> Map.get(:attributes, %{})
                                 |> Map.get("objectclass")
    end

  end

  describe "replace/3" do

    test "replaces values for an attribute with another list of values" do
      assert ["bird", "pigeon"] = Entry.replace(@entry, "objectclass", ["bird", "pigeon"])
                                  |> Map.get(:attributes, %{})
                                  |> Map.get("objectclass")
    end

  end

  describe "replace/4" do

    test "replaces a value for an attribute with another one" do
      assert ["top", "person", "examplePerson"] = Entry.replace(
                                                    @entry,
                                                    "objectclass",
                                                    "organizationalPerson",
                                                    "examplePerson"
                                                  )
                                                  |> Map.get(:attributes, %{})
                                                  |> Map.get("objectclass")
    end

  end

  describe "to_map/2" do

    test "converts an entry struct to a simple map" do
      assert %{} = Entry.to_map(@entry)
    end

    test "the map has snake_cased atom keys" do
      assert [
               :description,
               :title,
               :cn,
               :dn,
               :object_class,
               :surname,
               :telephone_number,
               :username
             ] = Entry.to_map(
                   @entry
                 )
                 |> Map.keys()
    end

  end

end