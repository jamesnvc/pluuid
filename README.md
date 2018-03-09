# pluuid

This library provides predicates for dealing with UUIDs in Prolog.

It can be installed in SWI-Prolog using `pack_install(pluuid).`

## Examples

```prolog
?- random_uuid(UUID), uuid_atom(UUID, Atom).
UUID = uuid(7100215486400447724, 1339227574425780922),
Atom = '6289085d-c7a0-44ec-1295-e462270e82ba'.
```

```prolog
?- uuid_atom(UUID, '9b5ee764-c1a2-4b23-9ed5-ca8644863c79').
UUID = uuid(-7251103930088535261, -7001467367653491591).
```
