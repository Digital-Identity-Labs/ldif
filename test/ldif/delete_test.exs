defmodule DeleteTest do
  use ExUnit.Case

  alias LDIF.Delete
  alias LDIF.Entry

  @dn  "cn=Robert Jensen, ou=Marketing, dc=airius, dc=com"
  @attrs %{
    "changetype" => "delete"
  }

  describe "new/2" do

    test "returns Delete struct" do
      assert %Delete{} = Delete.new(@dn, @attrs)
    end

    test "DN is present" do
      assert %Delete{dn: @dn} = Delete.new(@dn, @attrs)
    end

  end

  describe "apply_to/2" do

    test "returns nil if the passed entry matches the DN" do
      change = Delete.new(@dn, @attrs)
      assert [] = Delete.apply_to(change, %Entry{dn: @dn})
    end

    test "returns the Entry unchanged if the passed entry does not match the DN" do
      change = Delete.new("cn=Bob Jensen, ou=Marketing, dc=airius, dc=com", @attrs)
      assert [%Entry{dn: @dn}] = Delete.apply_to(change, %Entry{dn: @dn})
    end

  end
end