# UUID for Prolog

This library provides predicates for dealing with UUIDs in Prolog.

There is supposed to be [a `uuid` library already provided](http://www.swi-prolog.org/pldoc/man?section=uuid), but it seems not to be provided in my distribution and seems to not be able to parse a uuid from a given string.
Also, because the [initial purpose](https://github.com/braidchat/schedulebot) of this library is to communicate via Transit, I wanted the canonical representation of the UUIDs to be two 64-bit signed integers (as that's how they're represented in Transit+MsgPack, which is what Braid uses).
If neither of those things are important to you, you may as well use the one that comes with SWI-Prolog.

It can be installed in SWI-Prolog using `pack_install(uuid).`

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
