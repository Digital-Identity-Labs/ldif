defmodule ModDNTest do
  use ExUnit.Case
  alias LDIF.ModDN
  alias LDIF.Entry

  @dn "ou=PD Accountants, ou=Product Development, dc=airius, dc=com"
  @changes %{
    "changetype" => ["modrdn"],
    "newrdn" => ["ou=Product Development Accountants"],
    "deleteoldrdn" => ["1"],
    "newsuperior" => ["ou=Accounting, dc=airius, dc=com"]
  }


  describe "new/2" do

    test "returns ModDN struct" do
      assert %ModDN{} = ModDN.new(@dn, @changes)
    end

    test "contains the target entry's DN" do
      assert %ModDN{dn: @dn} = ModDN.new(@dn, @changes)
    end

    test "NewRDN is available if present" do
      assert %ModDN{newrdn: "ou=Product Development Accountants"} = ModDN.new(@dn, @changes)
    end

    test "deleteoldrd is available if present, as a boolean" do
      assert %ModDN{deleteoldrdn: true} = ModDN.new(@dn, @changes)
    end

    test "deleteoldrd defaults to false" do
      assert %ModDN{deleteoldrdn: false} = ModDN.new(@dn, %{@changes | "deleteoldrdn" => nil})
    end

    test "Newsuperior is available if present" do
      assert %ModDN{newsuperior: "ou=Accounting, dc=airius, dc=com"} = ModDN.new(@dn, @changes)
    end

  end

  #     %ModDN{dn: dn, newsuperior: newsuperior, deleteoldrdn: deleteoldrdn, newrdn: newrdn}

  describe "apply/2" do

        test "returns the Entry unchanged if the passed entry does not match the DN" do
          change = ModDN.new("cn=Bob Jensen, ou=Marketing, dc=airius, dc=com", @changes)
          assert %Entry{dn: @dn} = ModDN.apply(change, %Entry{dn: @dn})
        end

        test "returns an entry with an adjusted rdn if set to do so" do
          change = %ModDN{dn: @dn, newrdn: "ou=Product Development Accountants"}
          assert %Entry{dn: "ou=Product Development Accountants, ou=Product Development, dc=airius, dc=com"} = ModDN.apply(change, %Entry{dn: @dn})
        end

        test "returns an entry with an adjusted superior if set to do so" do
          change = %ModDN{dn: @dn, newsuperior: "ou=Accounting, dc=airius, dc=com"}
          assert %Entry{dn: "ou=PD Accountants, ou=Accounting, dc=airius, dc=com"} = ModDN.apply(change, %Entry{dn: @dn})

        end

        test "returns an adjusted entry and the original in a list if set to do so" do
          change = %ModDN{dn: @dn, newrdn: "ou=Product Development Accountants", deleteoldrdn: false}
          assert [
          %Entry{dn: "ou=Product Development Accountants, ou=Product Development, dc=airius, dc=com"},
          %Entry{dn: @dn},
          ] = ModDN.apply(change, %Entry{dn: @dn})

        end

        test "both rnd and superior can be changed together" do
          change = %ModDN{dn: @dn, newrdn: "ou=Product Development Accountants", newsuperior: "ou=Accounting, dc=airius, dc=com"}
          assert %Entry{dn: "ou=Product Development Accountants, ou=Accounting, dc=airius, dc=com"} = ModDN.apply(change, %Entry{dn: @dn})

        end

  end

end