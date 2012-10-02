let run_str str =
  let temp_in = Runtime.temp_file () in
  let str_c = open_out temp_in in
    output_string str_c str;
    close_out str_c;

    let in_c = open_in temp_in in
    let temp_out = Runtime.temp_file () in
    let out_c = open_out temp_out in
      (let open Repl in
         repl {
           stdin = in_c;
           stdout = out_c;
           lexbuf = None;
           interactive = false;
           print_result = true;
         });
      close_in in_c;
      close_out out_c;

      let rst_c = open_in temp_out in
      let rec go () =
        try let line = input_line rst_c in line :: go ()
        with End_of_file -> []
      in String.concat "\n" (go ())
;;

let test str rst =
  assert (run_str str = rst)
;;

let test_exn str expected =
  try (ignore (run_str str); assert false)
  with catched -> assert (catched = expected)
;;

let get_exn func =
  try func (); Failure "unreachable" with
    | expn -> expn
;;
