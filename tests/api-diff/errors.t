  $ mkdir repro
  $ cd repro

  $ cat > dune-project <<EOF
  > (lang dune 2.9)
  > EOF

  $ cat > dune <<EOF
  > (library
  >  (wrapped false)
  >  (name base))
  > EOF

  $ cat > bytes_intf.ml <<EOF
  > module type X = sig end
  > module type Y = sig
  >  module Z : X
  > end
  > EOF

  $ cat > bytes.ml <<EOF
  > module Z = Bytes_intf.X
  > EOF

  $ cat > bytes.mli <<EOF
  > include Bytes_intf.Y
  > EOF

  $ dune build
  File "bytes.ml", line 1, characters 11-23:
  1 | module Z = Bytes_intf.X
                 ^^^^^^^^^^^^
  Error: Unbound module "Bytes_intf.X"
  Hint: There is a module type named "Bytes_intf.X", but module types are not modules
  [1]

  $ print_types _build/default/.base.objs/byte/bytes.cmi
  cmi_name: Bytes
  cmi_sign:
  module Z
    Bytes_intf!.X
  


  $ print_types _build/default/.base.objs/byte/bytes_intf.cmi
  cmi_name: Bytes_intf
  cmi_sign:
  module type X
  module type Y
  

  $ api-diff --main-module bytes _build/default/.base.objs/byte _build/default/.base.objs/byte
  api-diff: Could not find module X in Bytes_intf
  [123]


api-diff only accepts arguments of the same nature, that is it either
diff a .cmi file with another .cmi file or a directory with a directory

  $ mkdir test
  $ touch test.cmi
  $ api-diff test test.cmi
  api-diff: Arguments must either both be directories or both single .cmi files.
  [123]

When diffing all libraries, the Either --main-module or --unwrapped must be specified

  $ mkdir test2
  $ api-diff test test2
  api-diff: Either --main-module or --unwrapped must be provided when diffing entire libraries.
  [123]

When passing --main-module and/or --unwrapped while diffing single .cmi files, the user will be warn
that it is ignored

  $ touch test2.cmi
  $ api-diff --main-module main test.cmi test2.cmi
  api-diff: --main-module is ignored when diffing single .cmi files
  api-diff: Cmi_format.Error(_)
  [123]

  $ touch test2.cmi
  $ api-diff --unwrapped test.cmi test2.cmi
  api-diff: --unwrapped is ignored when diffing single .cmi files
  api-diff: Cmi_format.Error(_)
  [123]

  $ touch test2.cmi
  $ api-diff --main-module main --unwrapped test.cmi test2.cmi
  api-diff: --main-module and --unwrapped are ignored when diffing single .cmi files
  api-diff: Cmi_format.Error(_)
  [123]
