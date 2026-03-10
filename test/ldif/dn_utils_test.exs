defmodule DNUtilsTest do
  use ExUnit.Case
  #doctest Ldif

  alias LDIF.DNUtils

  @dn "cn=Barbara Jensen, ou=Product Development, dc=airius, dc=com"
  @ndn "cn=barbara jensen,ou=product development,dc=airius,dc=com"
  @shoddy_dn " UID = JOHN.DOE , OU = PEOPLE , DC = EXAMPLE , DC = COM"

  describe "normalize_dn/1" do
    test "returns DN normalized to lose extra spaces and be downcased" do
     assert "uid=john.doe,ou=people,dc=example,dc=com" = DNUtils.normalize_dn(@shoddy_dn)
    end
  end

  describe "rdn/1" do
    test "returns the normalized RDN from a DN" do
      assert "cn=Barbara Jensen" = DNUtils.rdn(@dn)
    end
  end
  
  describe "nrdn/1" do
    test "returns the normalized RDN from a DN" do
      assert "uid=john.doe" = DNUtils.nrdn(@shoddy_dn)
    end
  end

  describe "superior/1" do
    test "returns the normalized superior DN from a DN" do
      assert "OU = PEOPLE , DC = EXAMPLE , DC = COM" = DNUtils.superior(@shoddy_dn)
      assert "ou=Product Development, dc=airius, dc=com" = DNUtils.superior(@dn)
      assert "ou=product development,dc=airius,dc=com" = DNUtils.superior(@ndn)
    end
  end

  describe "add_rdn/1" do
    test "returns a DN extended with an additional RDN" do
      assert "uid=johnbot, UID = JOHN.DOE , OU = PEOPLE , DC = EXAMPLE , DC = COM" = DNUtils.add_rdn(@shoddy_dn, "uid=johnbot")
    end
  end

  describe "replace_rdn/1" do
    test "returns a DN with the RDN replaced by a new RDN" do
      assert "uid=bob, OU = PEOPLE , DC = EXAMPLE , DC = COM" = DNUtils.replace_rdn(@shoddy_dn, "uid=bob")
      assert "uid=bob, ou=Product Development, dc=airius, dc=com" = DNUtils.replace_rdn(@dn, "uid=bob")
      assert "uid=bob,ou=product development,dc=airius,dc=com" = DNUtils.replace_rdn(@ndn, "uid=bob")
    end
  end

  describe "replace_superior/1" do
    test "returns " do
      assert "UID = JOHN.DOE,ou=staff,dc=example,dc=com" = DNUtils.replace_superior(@shoddy_dn, "ou=staff,dc=example,dc=com")
      assert "cn=Barbara Jensen,ou=staff,dc=example,dc=com" = DNUtils.replace_superior(@dn, "ou=staff,dc=example,dc=com")
      assert "cn=barbara jensen,ou=staff,dc=example,dc=com" = DNUtils.replace_superior(@ndn, "ou=staff,dc=example,dc=com")
      assert "cn=barbara jensen, ou=staff, dc=example, dc=com" = DNUtils.replace_superior(@ndn, "ou=staff, dc=example, dc=com")
      
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