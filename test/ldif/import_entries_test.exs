defmodule ImportEntriesTest do
  use ExUnit.Case

  alias LDIF.Entry
  alias LDIF.Import.Entries

  @entries File.read!("test/support/rfc_jensen_entries.ldif")

  describe "import/2" do

    test "converts a binary/string into a stream of Entry structs" do

      assert %Stream{} = Entries.import(@entries)

      assert [
               %Entry{dn: "ou=Product Development, dc=airius, dc=com"},
               %Entry{dn: "ou=PD Accountants, ou=Product Development, dc=airius, dc=com"},
               %Entry{dn: "ou=Accounting, dc=airius, dc=com"},
               %Entry{dn: "ou=Product Testing, dc=airius, dc=com"},
               %Entry{dn: "cn=Barbara Jensen, ou=Product Development, dc=airius, dc=com"},
               %Entry{dn: "cn=Bjorn Jensen, ou=Accounting, dc=airius, dc=com"},
               %Entry{dn: "cn=Ingrid Jensen, ou=Product Support, dc=airius, dc=com"},
               %Entry{dn: "cn=Gern Jensen, ou=Product Testing, dc=airius, dc=com"},
               %Entry{dn: "ou=営業部,o=Airius"},
               %Entry{dn: "uid=rogasawara,ou=営業部,o=Airius"},
               %Entry{dn: "cn=Horatio Jensen, ou=Product Testing, dc=airius, dc=com"}
             ] = Entries.import(@entries)
                 |> Enum.to_list()
    end

    test "handles wrapped lines automatically" do

      text =
        """
        version: 1
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

      desc = "Babs is a big sailing fan, and travels extensively in search of perfect sailing conditions."
      assert %Entry{
               attributes: %{
                 "description" => [^desc]
               }
             } = Entries.import(text, [])
                 |> Enum.to_list()
                 |> List.first()


    end

    test "will not truncate lang tags by default" do
      text =
        """
        dn:: b3U95Za25qWt6YOoLG89QWlyaXVz
        # dn:: ou=<JapaneseOU>,o=Airius
        objectclass: top
        objectclass: organizationalUnit
        ou:: 5Za25qWt6YOo
        # ou:: <JapaneseOU>
        ou;lang-ja:: 5Za25qWt6YOo
        # ou;lang-ja:: <JapaneseOU>
        ou;lang-ja;phonetic:: 44GI44GE44GO44KH44GG44G2
        # ou;lang-ja:: <JapaneseOU_in_phonetic_representation>
        ou;lang-en: Sales
        description: Japanese office
        """

      assert [
               "description",
               "objectclass",
               "ou",
               "ou;lang-en",
               "ou;lang-ja",
               "ou;lang-ja;phonetic"
             ] = Entries.import(
                   text,
                   []
                 )
                 |> Enum.to_list()
                 |> List.first()
                 |> Map.get(
                      :attributes
                    )
                 |> Map.keys()

    end

    test "will truncate lang tags if langs-tags option is set to false" do
      text =
        """
        dn:: b3U95Za25qWt6YOoLG89QWlyaXVz
        # dn:: ou=<JapaneseOU>,o=Airius
        objectclass: top
        objectclass: organizationalUnit
        ou:: 5Za25qWt6YOo
        # ou:: <JapaneseOU>
        ou;lang-ja:: 5Za25qWt6YOo
        # ou;lang-ja:: <JapaneseOU>
        ou;lang-ja;phonetic:: 44GI44GE44GO44KH44GG44G2
        # ou;lang-ja:: <JapaneseOU_in_phonetic_representation>
        ou;lang-en: Sales
        description: Japanese office
        """

      assert ["description", "objectclass", "ou"] = Entries.import(text, lang_tags: false)
                                                    |> Enum.to_list()
                                                    |> List.first()
                                                    |> Map.get(:attributes)
                                                    |> Map.keys()

    end

    test "will ignore lines beginning with #" do
      text =
        """
        # Example
        dn: cn=Barbara Jensen, ou=Product Development, dc=airius, dc=com
        #dn: cn=Babs Jensen, ou=Product Development, dc=airius, dc=com
        objectclass: top
        objectclass: person
        cn: Barbara Jensen
        sn: Jensen
        #uid: bjensen
        """

      assert ["cn", "objectclass", "sn"] = Entries.import(text)
                                           |> Enum.to_list()
                                           |> List.first()
                                           |> Map.get(:attributes)
                                           |> Map.keys()

    end

    test "will embed files if ext_files option is set" do

      File.write!("/tmp/description.txt", "Test Description")

      text =
        """
        dn: Horatio N Jensen, ou=Product Development, dc=airius, dc=com
        cn: Horatio N Jensen
        objectclass: top
        objectclass: person
        description:< file:///tmp/description.txt
        """

      assert %Entry{
               attributes: %{
                 "description" => ["Test Description"]
               }
             } = Entries.import(text, ext_files: true)
                 |> Enum.to_list()
                 |> List.first()

    end

    test "will raise an exception if asked to embed files and ext_files option is not set to true" do

      text =
        """
        dn: Horatio N Jensen, ou=Product Development, dc=airius, dc=com
        cn: Horatio N Jensen
        objectclass: top
        objectclass: person
        description:< file:///tmp/description.txt
        """

      assert_raise RuntimeError, fn ->
        Entries.import(text, ext_files: false)
        |> Enum.to_list()
        |> List.first()
      end

    end

    test "will embed resources over http if ext_http option is set" do
      text =
        """
        dn: Horatio N Jensen, ou=Product Development, dc=airius, dc=com
        cn: Horatio N Jensen
        objectclass: top
        objectclass: person
        description:< https://www.rfc-editor.org/rfc/rfc2849
        """

      assert %Entry{
               attributes: %{
                 "description" => ["\n<!DOCTYPE html" <> _]
               }
             } = Entries.import(text, ext_http: true)
                 |> Enum.to_list()
                 |> List.first()

    end

    test "will raise an exception if requested to embed resources over http and ext_http option is not set to true" do

      text =
        """
        dn: Horatio N Jensen, ou=Product Development, dc=airius, dc=com
        cn: Horatio N Jensen
        objectclass: top
        objectclass: person
        description:< https://www.rfc-editor.org/rfc/rfc2849
        """

      assert_raise RuntimeError, fn ->
        Entries.import(text, ext_http: false)
        |> Enum.to_list()
        |> List.first()
      end

    end

    test "will normalize entry DNs if normalize_dns option is set to true" do
      assert [
               %Entry{dn: "ou=product development,dc=airius,dc=com"},
               %Entry{dn: "ou=pd accountants,ou=product development,dc=airius,dc=com"},
               %Entry{dn: "ou=accounting,dc=airius,dc=com"},
               %Entry{dn: "ou=product testing,dc=airius,dc=com"},
               %Entry{dn: "cn=barbara jensen,ou=product development,dc=airius,dc=com"},
               %Entry{dn: "cn=bjorn jensen,ou=accounting,dc=airius,dc=com"},
               %Entry{dn: "cn=ingrid jensen,ou=product support,dc=airius,dc=com"},
               %Entry{dn: "cn=gern jensen,ou=product testing,dc=airius,dc=com"},
               %Entry{dn: "ou=営業部,o=airius"},
               %Entry{dn: "uid=rogasawara,ou=営業部,o=airius"},
               %Entry{dn: "cn=horatio jensen,ou=product testing,dc=airius,dc=com"}
             ] = Entries.import(@entries, normalize_dns: true)
                 |> Enum.to_list()
    end

    test "will not normalize entry DNs if normalize_dns option is set to false, or missing" do

      assert [
               %Entry{dn: "ou=Product Development, dc=airius, dc=com"},
               %Entry{dn: "ou=PD Accountants, ou=Product Development, dc=airius, dc=com"},
               %Entry{dn: "ou=Accounting, dc=airius, dc=com"},
               %Entry{dn: "ou=Product Testing, dc=airius, dc=com"},
               %Entry{dn: "cn=Barbara Jensen, ou=Product Development, dc=airius, dc=com"},
               %Entry{dn: "cn=Bjorn Jensen, ou=Accounting, dc=airius, dc=com"},
               %Entry{dn: "cn=Ingrid Jensen, ou=Product Support, dc=airius, dc=com"},
               %Entry{dn: "cn=Gern Jensen, ou=Product Testing, dc=airius, dc=com"},
               %Entry{dn: "ou=営業部,o=Airius"},
               %Entry{dn: "uid=rogasawara,ou=営業部,o=Airius"},
               %Entry{dn: "cn=Horatio Jensen, ou=Product Testing, dc=airius, dc=com"}
             ] = Entries.import(@entries, normalize_dns: false)
                 |> Enum.to_list()

      assert [
               %Entry{dn: "ou=Product Development, dc=airius, dc=com"},
               %Entry{dn: "ou=PD Accountants, ou=Product Development, dc=airius, dc=com"},
               %Entry{dn: "ou=Accounting, dc=airius, dc=com"},
               %Entry{dn: "ou=Product Testing, dc=airius, dc=com"},
               %Entry{dn: "cn=Barbara Jensen, ou=Product Development, dc=airius, dc=com"},
               %Entry{dn: "cn=Bjorn Jensen, ou=Accounting, dc=airius, dc=com"},
               %Entry{dn: "cn=Ingrid Jensen, ou=Product Support, dc=airius, dc=com"},
               %Entry{dn: "cn=Gern Jensen, ou=Product Testing, dc=airius, dc=com"},
               %Entry{dn: "ou=営業部,o=Airius"},
               %Entry{dn: "uid=rogasawara,ou=営業部,o=Airius"},
               %Entry{dn: "cn=Horatio Jensen, ou=Product Testing, dc=airius, dc=com"}
             ] = Entries.import(@entries)
                 |> Enum.to_list()

    end

    test "will exclude attributes that are on the reject option list" do
      text =
        """
        # Example
        dn: cn=Barbara Jensen, ou=Product Development, dc=airius, dc=com
        objectclass: top
        objectclass: person
        cn: Barbara Jensen
        sn: Jensen
        """

      assert ["objectclass", "sn"] = Entries.import(text, reject: ["cn"])
                                     |> Enum.to_list()
                                     |> List.first()
                                     |> Map.get(:attributes)
                                     |> Map.keys()

    end

    test "attributes on the single value option's list will be a string, not a list" do
      text =
        """
        # Example
        dn: cn=Barbara Jensen, ou=Product Development, dc=airius, dc=com
        objectclass: top
        objectclass: person
        cn: Barbara Jensen
        cn: Babs Jensen
        sn: Jensen
        """

      assert "Barbara Jensen" = Entries.import(text, single_value: ["cn"])
                                |> Enum.to_list()
                                |> List.first()
                                |> Map.get(:attributes)
                                |> Map.get("cn")


    end

    test "attributes on the redact option's list will be replaced" do
      text =
        """
        # Example
        dn: cn=Barbara Jensen, ou=Product Development, dc=airius, dc=com
        objectclass: top
        objectclass: person
        cn: Barbara Jensen
        cn: Babs Jensen
        sn: Jensen
        password: secret
        password: other_secret
        """

      assert ["********", "********"] = Entries.import(text, redact: ["password"])
                                        |> Enum.to_list()
                                        |> List.first()
                                        |> Map.get(:attributes)
                                        |> Map.get("password")


    end

    #    test "HTTP options for Req can be specified via the http option" do
    #
    #    end

    test "will convert encoded text into unicode" do
      text =
        """
        dn:: b3U95Za25qWt6YOoLG89QWlyaXVz
        objectclass: top
        objectclass: organizationalUnit
        ou:: 5Za25qWt6YOo
        ou;lang-ja:: 5Za25qWt6YOo
        ou;lang-ja;phonetic:: 44GI44GE44GO44KH44GG44G2
        ou;lang-en: Sales
        description: Japanese office
        """

      assert %Entry{
               dn: "ou=営業部,o=Airius",
               attributes: %{
                 "description" => ["Japanese office"],
                 "objectclass" => ["top", "organizationalUnit"],
                 "ou" => ["営業部", "営業部", "えいぎょうぶ", "Sales"]
               }
             }
             = Entries.import(text, lang_tags: false)
               |> Enum.to_list()
               |> List.first()
    end

    test "will convert Base64 encoded binary values into binary values, such as image data" do

      text =
        """
        # Example
        dn: cn=Barbara Jensen, ou=Product Development, dc=airius, dc=com
        objectclass: top
        objectclass: person
        cn: Barbara Jensen
        cn: Babs Jensen
        sn: Jensen
        jpegPhoto:: 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
          fDk+IF4AYuCK6X0lWELGnnzc//Z
        """

      assert ["\xFF\xD8\xFF\xDB\0C" <> _] = Entries.import(text)
                                            |> Enum.to_list()
                                            |> List.first()
                                            |> Map.get(:attributes)
                                            |> Map.get("jpegPhoto")

    end

  end

end