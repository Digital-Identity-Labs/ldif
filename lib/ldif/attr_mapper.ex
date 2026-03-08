defmodule LDIF.AttrMapper do

  require Logger

  @attr_map %{
    "c" => :country,
    "carlicense" => :car_license,
    "cn" => :cn,
    "objectclass" => :object_class,
    "departmentnumber" => :department_number,
    "departmentNumber" => :department_number,
    "description" => :description,
    "displayname" => :display_name,
    "edupersonaffiliation" => :edu_person_affiliation,
    "edupersondisplaypronouns" => :edu_person_display_pronouns,
    "edupersonentitlement" => :edu_person_entitlement,
    "edupersonorcid" => :edu_person_orcid,
    "edupersonorgdn" => :edu_person_org_dn,
    "edupersonorgunitdn" => :edu_person_org_unit_dn,
    "edupersonprimaryaffiliation" => :edu_person_primary_affiliation,
    "edupersonprimaryorgunitdn" => :edu_person_org_unit_dn,
    "edupersonprincipalname" => :edu_person_principal_name,
    "edupersonscopedaffiliation" => :edu_person_scoped_affiliation,
    "employeenumber" => :employee_number,
    "employeetype" => :employee_type,
    "givenname" => :given_name,
    "initials" => :initials,
    "l" => :location,
    "labeleduri" => :labeled_uri,
    "mail" => :mail,
    "memberof" => :member_of,
    "mobile" => :mobile,
    "o" => :org,
    "ou" => :org_unit,
    "personaltitle" => :personal_title,
    "postaladdress" => :postal_address,
    "preferredlanguage" => :preferred_language,
    "roomnumber" => :room_number,
    "schachomeorganization" => :schac_home_organization,
    "schachomeorganizationtype" => :schac_home_organization_type,
    "sshpublickey" => :ssh_public_key,
    "sn" => :surname,
    "telephonenumber" => :telephone_number,
    "title" => :title,
    "uid" => :username,
    "uidnumber" => :uid_number
  }

  def entry_to_map(entry, opts \\ []) do
    entry.attributes
    |> Enum.map(fn {k, v} -> {to_sca(k, opts), v} end)
    |> Enum.reject(fn {k, _} -> is_nil(k) end)
    |> Map.new()
    |> Map.put(:dn, entry.dn)
  end

  def default_attribute_map() do
    @attr_map
  end

  defp to_sca(key, opts) do
    mapper = opts[:attr_map] || @attr_map
    try do
      Map.get(mapper, String.downcase(key), nil) || String.to_existing_atom(Recase.to_snake(key))
    rescue
      _oops ->
        Logger.warning ("Attribute's snake-case name derived from '#{key}' is not already an existing atom, dropping attribute!")
        nil
    end
  end

end
