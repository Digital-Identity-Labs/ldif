# LDIF

LDIF is a simple Elixir parser for LDAP Data Interchange Format ([LDIF](https://en.wikipedia.org/wiki/LDAP_Data_Interchange_Format)) text files. 
It will convert the entries within them to Elixir structs, and can directly apply LDIF change records to normal
LDIF records.

[RFC 2849](https://www.rfc-editor.org/rfc/rfc2849) describes LDIF as:

> ... a file format suitable for describing
> directory information or modifications made to directory information.
> The file format, known as LDIF, for LDAP Data Interchange Format, is
> typically used to import and export directory information between
> LDAP-based directory servers, or to describe a set of changes which
> are to be applied to a directory.

The LDIF format is commonly used for importing records and changes into LDAP directories such as
[OpenLDAP](https://www.openldap.org). Records are typically for contact details, user accounts, groups and
departments but can be for any information.

Here is an example LDIF record: 

```ldif
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
```

[![Hex pm](http://img.shields.io/hexpm/v/ldif.svg?style=flat)](https://hex.pm/packages/ldif)
[![API Docs](https://img.shields.io/badge/api-docs-yellow.svg?style=flat)](http://hexdocs.pm/ldif/)
![Github Elixir CI](https://github.com/Digital-Identity-Labs/ldif/workflows/ElixirCI/badge.svg)

[![Run in Livebook](https://livebook.dev/badge/v1/blue.svg)](https://livebook.dev/run?url=https%3A%2F%2Fraw.githubusercontent.com%2FDigital-Identity-Labs%2Fldif%2Frefs%2Fheads%2Fmain%2Fldif_workbook.livemd)
## Features

* Import normal LDAP directory entries from a string or a file, as a list of structs.
* Import LDIF-formatted changes and apply to them to a list of entries
* Supports including external data in entry attributes. Both file:// and https:// are supported but optional
* Binary data such as images and encoded text should be parsed correctly
* A few utility functions are provided to directly modify entries - you can change DNs, adjust attribute values and
  so on.

  The top level `LDIF` module could contain all the functions you need but the following other modules may be of use:

* `LDIF.Sigil` provides a sigil for importing LDIF data in documentation and tests
* `LDIF.Entry` has various features for working with LDIF entries

## Caveats

* This is an early release that *probably* does the one thing I need it to do: adequately import LDIF records.
* It can apply changes to entries directly, skipping the LDAP server, but I've not used this in production. Is it
  reliable or actually useful? I don't know.
* There is no export feature yet. Please let me know if you'd find this useful.

## Examples

### Importing an LDIF of directory entries

```elixir
ldif = File.read!("test/support/rfc_jensen_entries.ldif")

LDIF.decode_entries!(ldif)
|> List.first()
#=> %LDIF.Entry{dn: "ou=Product Development, dc=airius, dc=com", attributes: %{"objectClass" => ["top", "organizationalUnit"],"ou" => ["Product Development"]}}
```

### Using a sigil to parse LDIF, then reading an attribute

```elixir

    require LDIF.Sigil

    ~L"""
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
    |> List.first()
    |> LDIF.Entry.attribute("cn")
    #=> ["Barbara Jensen", "Barbara J Jensen", "Babs Jensen"]
```

### Applying changes to a list of entries

```elixir
entries = File.read!("test/support/rfc_jensen_entries.ldif")
          |> LDIF.decode_entries!(ldif)

changes = File.read!("test/support/rfc_jensen_changes.ldif")
          |> LDIF.decode_changes!(ldif)

LDIF.apply_changes!(changes, entries)
```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `LDIF` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ldif, "~> 0.1.1"}
  ]
end
```

## References

### LDIF Resources
* [LDAP Data Interchange Format, RFC 2849](https://www.rfc-editor.org/rfc/rfc2849)
* [LDIF at Wikipedia](https://en.wikipedia.org/wiki/LDAP_Data_Interchange_Format)
* [Language Tags and Ranges in the
  Lightweight Directory Access Protocol (LDAP) RFC 3866](https://datatracker.ietf.org/doc/html/rfc3866)

## Documentation

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/ldif>.

## Contributing

You can request new features by creating an [issue](https://github.com/Digital-Identity-Labs/ldif/issues),
or submit a [pull request](https://github.com/Digital-Identity-Labs/ldif/pulls) with your contribution.

If you are comfortable working with Python but this package's Elixir code is unfamiliar then this
blog post may help: [Elixir For Humans Who Know Python](https://hibox.live/elixir-for-humans-who-know-python)

This software was produced without generative AI and no contributions from generative AI will be accepted.  

## Copyright and License

Copyright (c) 2026 Digital Identity Ltd, UK

This software is MIT licensed.

## Disclaimer

This software may change considerably in the first few releases after 0.1.0 - it is not yet stable!