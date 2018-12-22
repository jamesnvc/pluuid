:- module(pluuid, [random_uuid/1, uuid_atom/2, uuid/1, uuid/2]).
:- use_module(library(crypto), [crypto_n_random_bytes/2, hex_bytes/2]).
:- use_module(library(list_util), [split/3]).

:- predicate_options(uuid/2, 2,
                     [ version(integer),
                       format(atom) ]).

% given a list of bytes in big-endian form, convert them to an integer
bytes_integer(Bs, N) :-
    foldl([B, N0, N1]>>(N1 is N0<<8 + B), Bs, 0, N).

unsigned64_signed64(Un, Si) :-
    integer(Un),
    Un >= 0x8000_0000_0000_0000,
    !,
    Inv is 0xffff_ffff_ffff_ffff - Un,
    Si is -Inv - 1.
unsigned64_signed64(Un, Si) :-
    integer(Si),
    Si < 0,
    !,
    Inv is -Si - 1,
    Un is 0xffff_ffff_ffff_ffff - Inv.
unsigned64_signed64(Un, Un).

%! random_uuid(-UUID) is det
% UUID is a random version-4 UUID, represented as `uuid(High64, Low64)`.
random_uuid(uuid(Hi, Lo)) :-
    crypto_n_random_bytes(8, HiBytes),
    bytes_integer(HiBytes, Hi64),
    % Set version in 4 sig bits of time_hi_and_version
    Hi_ is Hi64 /\ \ (0b1111 << 12 ),
    HiUn is Hi_ \/ (4 << 12),
    unsigned64_signed64(HiUn, Hi),

    crypto_n_random_bytes(8, LoBytes),
    bytes_integer(LoBytes, Lo64),
    % Set 2 sig bits of clock_seq_hi_res to 0 & 1
    Lo_ is Lo64 /\ \ (1 << (64-6)),
    LoUn is Lo_ \/ (1 << (64-7)),
    unsigned64_signed64(LoUn, Lo).

%! uuid_atom(-UUID, +Atom) is semidet.
%! uuid_atom(+UUID, -Atom) is det.
% Atom is equal to the hexadecimal representation of the version-4 UUID
uuid_atom(uuid(Hi_, Lo_), A) :-
    integer(Hi_), integer(Lo_), !,
    unsigned64_signed64(Hi, Hi_),
    unsigned64_signed64(Lo, Lo_),
    TimeLow is (Hi >> 32),
    TimeMid is (Hi >> 16) /\ 0xffff,
    TimeHi is Hi /\ 0xffff,
    ClockSeq is (Lo >> 48) /\ 0xffff,
    Node is Lo /\ 0xffff_ffff_ffff,
    format(atom(TL), '~`0t~16r~8|', [TimeLow]),
    format(atom(TM), '~`0t~16r~4|', [TimeMid]),
    format(atom(TH), '~`0t~16r~4|', [TimeHi]),
    format(atom(CS), '~`0t~16r~4|', [ClockSeq]),
    format(atom(N), '~`0t~16r~12|', [Node]),
    atomic_list_concat([TL, TM, TH, CS, N], '-', A).
uuid_atom(uuid(Hi, Lo), A) :-
    atom(A), !,
    atom_chars(A, Chars),
    split(Chars, '-', CharParts),
    maplist(atom_chars, AtomParts, CharParts),
    maplist(hex_bytes, AtomParts, Bytes),
    maplist(bytes_integer, Bytes, Nums),
    [TimeLow, TimeMid, TimeHi, ClockSeq, Node] = Nums,
    Hi_ is TimeLow << 32 + TimeMid << 16 + TimeHi,
    Lo_ is ClockSeq << 48 + Node,
    unsigned64_signed64(Hi_, Hi),
    unsigned64_signed64(Lo_, Lo).

%! uuid(-UUID) is det.
% Create a new, random v4 UUID as the atom representation.
% Copying the API of the built-in `library(uuid)`
uuid(UUID) :-
    random_uuid(U),
    uuid_atom(U, UUID).

%! uuid(-UUID, +Options) is det.
% Copying the API of the built-in `library(uuid)`
uuid(_UUID, Options) :-
    member(version(V), Options),
    V \= 4, !,
    throw(error(domain_error(4, V),
                context(uuid/2, 'Only version 4 UUIDs supported'))).
uuid(UUID, Options) :-
    memberchk(format(integer), Options), !,
    random_uuid(uuid(SHi, SLo)),
    unsigned64_signed64(Hi, SHi),
    unsigned64_signed64(Lo, SLo),
    UUID is Hi << 64 + Lo.
uuid(UUID, _Options) :-
    uuid(UUID).
