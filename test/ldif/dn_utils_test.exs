defmodule DNUtilsTest do
  use ExUnit.Case
  #doctest Ldif

  alias LDIF.DNUtils

  @shoddy_dn " UID = JOHN.DOE , OU = PEOPLE , DC = EXAMPLE , DC = COM"

  describe "normalize_dn/1" do
    test "returns DN normalized to lose extra spaces and be downcased" do
     assert "uid=john.doe,ou=people,dc=example,dc=com" = DNUtils.normalize_dn(@shoddy_dn)
    end
  end

  describe "rdn/1" do
    test "returns the normalized RDN from a DN" do
      assert "uid=john.doe" = DNUtils.rdn(@shoddy_dn)
    end
  end

  describe "superior/1" do
    test "returns the normalized superior DN from a DN" do
      assert "ou=people,dc=example,dc=com" = DNUtils.superior(@shoddy_dn)
    end
  end

  describe "add_rdn/1" do
    test "returns a DN extended with an additional RDN" do
      assert "uid=johnbot,uid=john.doe,ou=people,dc=example,dc=com" = DNUtils.add_rdn(@shoddy_dn, "uid=johnbot")
    end
  end

  describe "replace_rdn/1" do
    test "returns a DN with the RDN replaced by a new RDN" do
      assert "uid=bob,ou=people,dc=example,dc=com" = DNUtils.replace_rdn(@shoddy_dn, "uid=bob")
    end
  end

  describe "replace_superior/1" do
    test "returns " do
      assert "uid=john.doe,ou=staff,dc=example,dc=com" = DNUtils.replace_superior(@shoddy_dn, "ou=staff,dc=example,dc=com")
    end
  end

  describe "ancestor_of?/1" do
    test "returns true if the (first) DN is an ancestor of the second DN" do
      assert DNUtils.ancestor_of?(@shoddy_dn, "uid=johnbot,uid=john.doe,ou=people,dc=example,dc=com")
    end
  end

  describe "descendent_of?/1" do
    test "returns true if the (first) DN is a descendent of the second DN" do
      assert DNUtils.descendent_of?(@shoddy_dn, "dc=example,dc=com")
    end
  end



end