defmodule ImportRecordTest do
  use ExUnit.Case

  alias LDIF.Import.Record

  describe "stream/1" do

    test "takes LDIF text and produces a stream of text records, one for each entry" do

      text =
        """
        version: 1
        dn: ou=Product Development, dc=airius, dc=com
        ou: Product Development
        objectClass: top
        objectClass: organizationalUnit

        dn: ou=PD Accountants, ou=Product Development, dc=airius, dc=com
        ou: Product Development Accountants
        objectClass: top
        objectClass: organizationalUnit

        dn: ou=Accounting, dc=airius, dc=com
        ou: Accounting
        objectClass: top
        objectClass: organizationalUnit

        dn: ou=Product Testing, dc=airius, dc=com
        ou: Product Testing
        objectClass: top
        objectClass: organizationalUnit
        """

        assert is_function(Record.stream(text)) or is_struct(Record.stream(text), Stream)
        assert 4 = Record.stream(text) |> Enum.to_list() |> Enum.count()
        assert "version: 1\ndn: ou=Product Development, dc=airius, dc=com\nou: Product Development\nobjectClass: top\nobjectClass: organizationalUnit"
               = Record.stream(text) |> Enum.to_list() |> List.first()

    end

  end

  describe "unfold/2" do

    test "joins together indented/wrapped/folded lines in a block of text for one record" do
      text1 =
      """
      dn:cn=Barbara Jensen, ou=Product Development, dc=airius, dc=com
      objectclass:top
      objectclass:person
      description:Babs is a big sailing fan, and travels extensively in sea
        rch of perfect sailing conditions.
        This is an extra sentence.
      """

      text2 =
        """
        dn:cn=Barbara Jensen, ou=Product Development, dc=airius, dc=com
        objectclass:top
        objectclass:person
        description:Babs is a big sailing fan, and travels extensively in search of perfect sailing conditions. This is an extra sentence.
        """

      assert ^text2 = Record.unfold(text1)

    end

  end

  describe "split/2" do

    test "produces a list of lists for each line in the record" do

      text =
        """
        dn: ou=PD Accountants, ou=Product Development, dc=airius, dc=com
        ou: Product Development Accountants
        objectClass: top
        objectClass: organizationalUnit
        """

      assert [
               ["dn", "ou=PD Accountants, ou=Product Development, dc=airius, dc=com"],
               ["ou", "Product Development Accountants"],
               ["objectClass", "top"],
               ["objectClass", "organizationalUnit"]
             ] = Record.split(text)

    end


    test "removes leading version line" do
      text = """
      version: 1
      dn: ou=Product Development, dc=airius, dc=com
      ou: Product Development
      objectClass: top
      objectClass: organizationalUnit
      """

      assert [
               ["dn", "ou=Product Development, dc=airius, dc=com"],
               ["ou", "Product Development"],
               ["objectClass", "top"],
               ["objectClass", "organizationalUnit"]
             ] = Record.split(text)

    end

    test "removes lines beginning with a hash" do
      text = """
      # This is an example comment
      dn: ou=Product Development, dc=airius, dc=com
      ou: Product Development
      ## This is another comment with two octothorpes
      objectClass: top
      objectClass: organizationalUnit
      """

      assert [
               ["dn", "ou=Product Development, dc=airius, dc=com"],
               ["ou", "Product Development"],
               ["objectClass", "top"],
               ["objectClass", "organizationalUnit"]
             ] = Record.split(text)
    end

  end


end