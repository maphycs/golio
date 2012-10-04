open Type

let stdin =
  ref Void
;;

let stdout =
  ref Void
;;

let prim_ports () =
  [
    "stdin", !stdin;
    "stdout", !stdout;
  ]
;;

let init lb in_c out_c =
  stdin := input_port "#stdin" lb in_c;
  stdout := output_port "#stdout" out_c;
;;