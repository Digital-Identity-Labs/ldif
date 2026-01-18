defmodule ModifyTest do
  use ExUnit.Case

  alias LDIF.Modify
  alias LDIF.Entry

  @dn "cn=Ingrid Jensen, ou=Product Support, dc=airius, dc=com"

  @attrs %{
    "objectclass" => ["top", "person", "organizationalPerson"],
    "cn" => ["Ingrid Jensen"],
    "sn" => ["Jensen"],
    "telephonenumber" => ["+1 408 555 1212"],
    "postaladdress" => ["1 Everystreet $ Manchester, UK"],
    "description" => ["This is just here so we can delete it later"],
    "facsimiletelephonenumber" => ["+1 408 555 9876", "+1 408 555 9877"]
  }

  @changes_add %{
    "changetype" => ["modify"],
    "add" => ["postaladdress"],
    "postaladdress" => ["123 Anystreet $ Sunnyvale, CA $ 94086"]
  }
  @changes_del1 %{
    "changetype" => ["modify"],
    "delete" => ["description"]
  }
  @changes_del2 %{
    "changetype" => ["modify"],
    "delete" => ["facsimiletelephonenumber"],
    "facsimiletelephonenumber" => ["+1 408 555 9876"]
  }
  @changes_del3 %{
    "changetype" => ["modify"],
    "delete" => ["inscription"]
  }
  @changes_rep1 %{
    "changetype" => ["modify"],
    "replace" => ["telephonenumber"],
    "telephonenumber" => ["+1 408 555 1234", "+1 408 555 5678"]
  }
  @changes_rep2 %{
    "changetype" => ["modify"],
    "replace" => ["telephonenumber"],
    "telephonenumber" => []
  }
  @changes_rep3 %{
    "changetype" => ["modify"],
    "replace" => ["inscription"],
    "inscription" => []
  }

  describe "new/2" do

    test "returns ModDN struct" do
      assert %Modify{} = Modify.new(@dn, @changes_del2)
    end

    test "contains the target entry's DN" do
      assert %Modify{dn: @dn} = Modify.new(@dn, @changes_add)
    end

    test "contains the modification type" do
      assert %Modify{dn: @dn, modification: :add} = Modify.new(@dn, @changes_add)
      assert %Modify{dn: @dn, modification: :delete} = Modify.new(@dn, @changes_del1)
      assert %Modify{dn: @dn, modification: :replace} = Modify.new(@dn, @changes_rep1)
    end

    test "contains the attribute to change" do
      assert %Modify{dn: @dn, attribute: "postaladdress"} = Modify.new(@dn, @changes_add)
    end

    test "and contains the values to use in the change" do
      assert %Modify{dn: @dn, values: ["123 Anystreet $ Sunnyvale, CA $ 94086"]} = Modify.new(@dn, @changes_add)
    end

  end

  describe "apply/2" do

    test "returns the Entry unchanged if the passed entry does not match the DN" do
      change = Modify.new("cn=Bob Jensen, ou=Marketing, dc=airius, dc=com", @changes_add)
      assert %Entry{dn: @dn} = Modify.apply(change, %Entry{dn: @dn})
    end

    test "can add additional values to an existing attribute" do
      change = Modify.new(@dn, @changes_add)
      assert %Entry{
               attributes: %{
                 "postaladdress" =>
                   ["1 Everystreet $ Manchester, UK", "123 Anystreet $ Sunnyvale, CA $ 94086"]
               }
             } = Modify.apply(change, %Entry{dn: @dn, attributes: @attrs})
    end

    test "can add values to a missing attribute" do
      change = Modify.new(@dn, @changes_add)
      assert %Entry{
               attributes: %{
                 "postaladdress" =>
                   ["123 Anystreet $ Sunnyvale, CA $ 94086"]
               }
             } = Modify.apply(change, %Entry{dn: @dn, attributes: Map.delete(@attrs, "postaladdress")})
    end

    test "can delete an entire attribute if it exists" do
      change = Modify.new(@dn, @changes_del1)
      refute Map.has_key?(
               Modify.apply(change, %Entry{dn: @dn, attributes: @attrs})
               |> Map.get(:attributes, %{}),
               "description"
             )
    end

    test "will error if asked to delete an attribute that does not exist" do
      assert_raise RuntimeError, fn ->
        change = Modify.new(@dn, @changes_del3)
        Modify.apply(change, %Entry{dn: @dn, attributes: @attrs})
      end
    end

    test "can delete a specific value of an attribute" do
      change = Modify.new(@dn, @changes_del2)
      assert %Entry{
               attributes: %{
                 "facsimiletelephonenumber" => ["+1 408 555 9877"]
               }
             } = Modify.apply(change, %Entry{dn: @dn, attributes: @attrs})
    end

    test "can remove an attribute that exists by giving it no values" do
      change = Modify.new(@dn, @changes_rep2)
      refute Map.has_key?(Modify.apply(change, %Entry{dn: @dn, attributes: @attrs}).attributes, "telephonenumber")
    end

    test "will not error when asked to remove an attribute that does not exist by giving it no values" do
      change = Modify.new(@dn, @changes_rep3)
      refute Map.has_key?(Modify.apply(change, %Entry{dn: @dn, attributes: @attrs}).attributes, "inscription")
    end

    test "can replace the values of an attribute" do
      change = Modify.new(@dn, @changes_rep1)
      assert %Entry{
               attributes: %{
                 "telephonenumber" => ["+1 408 555 1234", "+1 408 555 5678"]
               }
             } = Modify.apply(change, %Entry{dn: @dn, attributes: @attrs})
    end

  end


end