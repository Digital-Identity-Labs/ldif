defmodule LDIF.AttrMapper do

  require Logger

  @attr_map %{
    "c" => :c,
    "carLicense" => :car_license,
    "cn" => :cn,
    "objectClass" => :object_class,
    "objectclass" => :object_class,
    "departmentNumber" => :department_number,
    "description" => :description,
    "displayName" => :display_name,
    "eduPersonAffiliation" => :edu_person_affiliation,
    "eduPersonDisplayPronouns" => :edu_person_display_pronouns,
    "eduPersonEntitlement" => :edu_person_entitlement,
    "eduPersonOrcid" => :edu_person_orcid,
    "eduPersonOrgDN" => :edu_person_org_dn,
    "eduPersonOrgUnitDN" => :edu_person_org_unit_dn,
    "eduPersonPrimaryAffiliation" => :edu_person_primary_affiliation,
    "eduPersonPrimaryOrgUnitDN" => :edu_person_org_unit_dn,
    "eduPersonPrincipalName" => :edu_person_principal_name,
    "eduPersonScopedAffiliation" => :edu_person_scoped_affiliation,
    "eduPersonAffiliation" => :edu_person_affiliation,
    "employeeNumber" => :employee_number,
    "employeeType" => :employee_type,
    "givenName" => :given_name,
    "initials" => :initials,
    "l" => :location,
    "labeledURI" => :labeled_uri,
    "mail" => :mail,
    "memberOf" => :member_of,
    "mobile" => :mobile,
    "o" => :org,
    "ou" => :org_unit,
    "personalTitle" => :personal_title,
    "postalAddress" => :postal_address,
    "preferredLanguage" => :preferred_language,
    "roomNumber" => :room_number,
    "schacHomeOrganization" => :schac_home_organization,
    "schacHomeOrganizationType" => :schac_home_organization_type,
    "sshPublicKey" => :ssh_public_key,
    "sn" => :surname,
    "telephoneNumber" => :telephone_number,
    "telephonenumber" => :telephone_number,
    "title" => :title,
    "uid" => :username,
    "uidNumber" => :uid_number
  }

  def entry_to_map(entry, opts \\ []) do
    entry.attributes
    |> Enum.map(fn {k, v} -> {to_sca(k, opts), v} end)
    |> Enum.reject(fn {k, _} -> is_nil(k) end)
    |> Map.new()
    |> Map.put(:dn, entry.dn)

  end

  defp to_sca(key, opts) do
    mapper = opts[:attr_map] || @attr_map
    try do
      Map.get(mapper, key, nil) || String.to_existing_atom(Recase.to_snake(key))
    rescue
      _oops ->
        Logger.warning ("Attribute's snake-case name '#{key}' is not already an existing atom, dropping attribute!")
        nil
    end
  end

end
