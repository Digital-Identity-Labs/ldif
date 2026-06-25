defmodule ImportChangesTest do
  use ExUnit.Case
  
  alias LDIF.Import.Changes

  @changes File.read!("test/support/rfc_jensen_changes.ldif")
  describe "changes/2" do

    test "converts a binary/string into a stream of change-specific structs" do

      assert is_function(Changes.import(@changes)) or is_struct(Changes.import(@changes), Stream)

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
                 newrdn: "cn=Paula Jensen",
                 newsuperior: nil
               },
               %LDIF.ModDN{
                 dn: "ou=PD Accountants, ou=Product Development, dc=airius, dc=com",
                 deleteoldrdn: false,
                 newrdn: "ou=Product Development Accountants",
                 newsuperior: "ou=Accounting, dc=airius, dc=com"
               },
               %LDIF.Modify{
                 dn: "cn=Paula Jensen, ou=Product Development, dc=airius, dc=com",
                 attribute: "postaladdress",
                 modification: :add,
                 values: ["123 Anystreet $ Sunnyvale, CA $ 94086"]
               },
               %LDIF.Modify{
                 dn: "cn=Paula Jensen, ou=Product Development, dc=airius, dc=com",
                 attribute: "description",
                 modification: :delete,
                 values: nil
               },
               %LDIF.Modify{
                 dn: "cn=Paula Jensen, ou=Product Development, dc=airius, dc=com",
                 attribute: "telephonenumber",
                 modification: :replace,
                 values: ["+1 408 555 1234", "+1 408 555 5678"]
               },
               %LDIF.Modify{
                 dn: "cn=Paula Jensen, ou=Product Development, dc=airius, dc=com",
                 attribute: "facsimiletelephonenumber",
                 modification: :delete,
                 values: ["+1 408 555 9876"]
               },
               %LDIF.Modify{
                 dn: "cn=Ingrid Jensen, ou=Product Support, dc=airius, dc=com",
                 attribute: "postaladdress",
                 modification: :replace,
                 values: nil
               },
               %LDIF.Modify{
                 dn: "cn=Ingrid Jensen, ou=Product Support, dc=airius, dc=com",
                 attribute: "description",
                 modification: :delete,
                 values: nil
               },
               %LDIF.Delete{dn: "ou=Product Development, dc=airius, dc=com"}
             ] = Changes.import(@changes)
                 |> Enum.to_list()
    end

    test "one change record may become multiple, ordered change entries" do
      text =
        """
        # Modify an entry: add an additional value to the postaladdress
        # attribute, completely delete the description attribute, replace
        # the telephonenumber attribute with two values, and delete a specific
        # value from the facsimiletelephonenumber attribute
        dn: cn=Paula Jensen, ou=Product Development, dc=airius, dc=com
        changetype: modify
        add: postaladdress
        postaladdress: 123 Anystreet $ Sunnyvale, CA $ 94086
        -
        delete: description
        -
        replace: telephonenumber
        telephonenumber: +1 408 555 1234
        telephonenumber: +1 408 555 5678
        -
        delete: facsimiletelephonenumber
        facsimiletelephonenumber: +1 408 555 9876
        -
        """

      assert [
               %LDIF.Modify{
                 dn: "cn=Paula Jensen, ou=Product Development, dc=airius, dc=com",
                 attribute: "postaladdress",
                 modification: :add,
                 values: ["123 Anystreet $ Sunnyvale, CA $ 94086"]
               },
               %LDIF.Modify{
                 dn: "cn=Paula Jensen, ou=Product Development, dc=airius, dc=com",
                 attribute: "description",
                 modification: :delete,
                 values: nil
               },
               %LDIF.Modify{
                 dn: "cn=Paula Jensen, ou=Product Development, dc=airius, dc=com",
                 attribute: "telephonenumber",
                 modification: :replace,
                 values: ["+1 408 555 1234", "+1 408 555 5678"]
               },
               %LDIF.Modify{
                 dn: "cn=Paula Jensen, ou=Product Development, dc=airius, dc=com",
                 attribute: "facsimiletelephonenumber",
                 modification: :delete,
                 values: ["+1 408 555 9876"]
               },
             ] = Changes.import(text)
                 |> Enum.to_list()


    end

    test "handles wrapped lines automatically" do

      text =
        """
        dn: cn=Fiona Jensen, ou=Marketing, dc=airius, dc=com
        changetype: add
        objectclass: top
        objectclass: person
        objectclass: organizationalPerson
        cn: Fiona Jensen
        sn: Jensen
        uid: fiona
        telephonenumber: +1 408 555 1212
        description: This is some text to test that line unwrapping happens for change 
          records too, because you can never be too careful with this sort of thing.
        """

      assert [
               "This is some text to test that line unwrapping happens for change records too, because you can never be too careful with this sort of thing."
             ] = Changes.import(text)
                 |> Enum.to_list()
                 |> List.first()
                 |> Map.get(:attributes)
                 |> Map.get("description")

    end

    test "will truncate lang tags if option is set" do
      text =
        """
        dn: cn=Fiona Jensen, ou=Marketing, dc=airius, dc=com
        changetype: add
        objectclass: top
        objectclass: person
        objectclass: organizationalPerson
        cn;lang-en: Fiona Jensen
        sn: Jensen
        uid: fiona
        telephonenumber: +1 408 555 1212
        """

      assert ["Fiona Jensen"] = Changes.import(text, lang_tags: false)
                                |> Enum.to_list()
                                |> List.first()
                                |> Map.get(:attributes)
                                |> Map.get("cn")

    end

    test "will embed files into attribute values if option is set" do
      text =
        """
        dn: cn=Fiona Jensen, ou=Marketing, dc=airius, dc=com
        changetype: add
        objectclass: top
        objectclass: person
        objectclass: organizationalPerson
        cn: Fiona Jensen
        sn: Jensen
        uid: fiona
        telephonenumber: +1 408 555 1212
        description:< file:///tmp/description.txt
        """

      assert %LDIF.Add{
               attributes: %{
                 "description" => ["Test Description"]
               }
             } = Changes.import(text, ext_files: true)
                 |> Enum.to_list()
                 |> List.first()

    end

    test "will embed resources over http into attributes if options is set" do
      text =
        """
        dn: cn=Fiona Jensen, ou=Marketing, dc=airius, dc=com
        changetype: add
        objectclass: top
        objectclass: person
        objectclass: organizationalPerson
        cn: Fiona Jensen
        sn: Jensen
        uid: fiona
        description:< https://www.rfc-editor.org/info/rfc2849/
        """

      assert %LDIF.Add{
               attributes: %{
                 "description" => ["<!DOCTYPE html" <> _]
               }
             } = Changes.import(text, ext_http: true)
                 |> Enum.to_list()
                 |> List.first()
    end

    test "will normalize entry DNs if options is set" do
      text =
        """
        dn: cn=Fiona Jensen, ou=Marketing, dc=airius, dc=com
        changetype: add
        objectclass: top
        objectclass: person
        objectclass: organizationalPerson
        cn: Fiona Jensen
        sn: Jensen
        uid: fiona
        telephonenumber: +1 408 555 1212
        """

      assert %LDIF.Add{dn: "cn=fiona jensen,ou=marketing,dc=airius,dc=com"} = Changes.import(text, normalize_dns: true)
                                                                         |> Enum.to_list()
                                                                         |> List.first()
    end

    test "will exclude attributes that are on the reject option list" do
      text =
        """
        dn: cn=Fiona Jensen, ou=Marketing, dc=airius, dc=com
        changetype: add
        objectclass: top
        objectclass: person
        objectclass: organizationalPerson
        cn: Fiona Jensen
        sn: Jensen
        uid: fiona
        telephonenumber: +1 408 555 1212
        """

      assert is_nil(
               Changes.import(text, reject: ["sn"])
               |> Enum.to_list()
               |> List.first()
               |> Map.get(:attributes)
               |> Map.get("sn")
             )
    end

    test "will redact values on the redact option list" do
      text =
        """
        dn: cn=Fiona Jensen, ou=Marketing, dc=airius, dc=com
        changetype: add
        objectclass: top
        objectclass: person
        objectclass: organizationalPerson
        cn: Fiona Jensen
        sn: Jensen
        uid: fiona
        telephonenumber: +1 408 555 1212
        """

      assert ["********"] = Changes.import(text, redact: ["uid"])
                            |> Enum.to_list()
                            |> List.first()
                            |> Map.get(:attributes)
                            |> Map.get("uid")
    end

    test "attributes on the single value option's list will be a string, not a list" do
      text =
        """
        dn: cn=Fiona Jensen, ou=Marketing, dc=airius, dc=com
        changetype: add
        objectclass: top
        objectclass: person
        objectclass: organizationalPerson
        cn: F Jensen
        cn: Fiona Jensen
        sn: Jensen
        uid: fiona
        telephonenumber: +1 408 555 1212
        """

      assert "F Jensen" = Changes.import(text, single_value: "cn")
                          |> Enum.to_list()
                          |> List.first()
                          |> Map.get(:attributes)
                          |> Map.get("cn")
    end

    #    test "HTTP options for Req can be specified via the http option" do
    #
    #    end

    test "will convert encoded text into unicode" do
      text =
        """
        dn: cn=Fiona Jensen, ou=Marketing, dc=airius, dc=com
        changetype: add
        objectclass: top
        objectclass: person
        objectclass: organizationalPerson
        ou:: 5Za25qWt6YOo
        cn: Fiona Jensen
        sn: Jensen
        uid: fiona
        """

      assert ["営業部"] = Changes.import(text, lang_tags: false)
                          |> Enum.to_list()
                          |> List.first()
                          |> Map.get(:attributes)
                          |> Map.get("ou")
    end

    test "will convert Base64 encoded binary values into binary values, such as image data" do
      text =
        """
        dn: cn=Fiona Jensen, ou=Marketing, dc=airius, dc=com
        changetype: add
        objectclass: top
        objectclass: person
        objectclass: organizationalPerson
        cn: Fiona Jensen
        sn: Jensen
        uid: fiona
        jpegPhoto:: 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
          fDk+IF4AYuCK6X0lWELGnnzc//Z
        """

      assert ["\xFF\xD8\xFF\xDB\0C" <> _] = Changes.import(text)
                                            |> Enum.to_list()
                                            |> List.first()
                                            |> Map.get(:attributes)
                                            |> Map.get("jpegPhoto")
    end

  end

end