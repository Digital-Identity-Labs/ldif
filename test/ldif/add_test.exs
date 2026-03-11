defmodule AddTest do
  use ExUnit.Case

  alias LDIF.Add
  alias LDIF.Entry

  @dn "cn=Fiona Jensen, ou=Marketing, dc=airius, dc=com"
  @attrs %{
    "changetype" => "add",
    "objectclass" => ["top", "person", "organizationalPerson"],
    "cn" => ["Fiona Jensen"],
    "sn" => ["Jensen"],
    "uid" => ["fiona"],
    "telephonenumber" => ["+1 408 555 1212"]
  }


  describe "new/2" do

    test "returns Add struct" do
      assert %Add{} = Add.new(@dn, @attrs)
    end

    test "DN is present" do
      assert %Add{dn: @dn} = Add.new(@dn, @attrs)
    end

    test "Attributes are present as a map, without changetype, if present" do
      attrs = Map.delete(@attrs, "changetype")
      assert %Add{attributes: ^attrs} = Add.new(@dn, @attrs)
      assert %Add{attributes: ^attrs} = Add.new(@dn, attrs)
    end

  end

  describe "apply/2" do

    test "returns Entry struct with the specified DN and attributes when nil is passed as an Entry" do
      attrs = Map.delete(@attrs, "changetype")
      change = Add.new(@dn, @attrs)
      assert [%Entry{dn: @dn, attributes: ^attrs}] = Add.apply(change, nil)
    end

    test "does not raise an exception if passed an Entry as well as a change" do
      change = Add.new(@dn, @attrs)
      assert [%Entry{dn: @dn}, %Entry{dn: "cn=banana"}] = Add.apply(change, %Entry{dn: "cn=banana"})
    end

  end

end