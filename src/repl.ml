open Type
include Common

let repl conf =
  Runtime.init ();
  let in_c = conf.stdin in
  let out_c = conf.stdout in
  let lb =
    match conf.lexbuf with
      | Some lb -> lb
      | None -> Lexing.from_channel in_c
  in
    Prim_port.init lb in_c out_c;
    let parse () = Parser.parse Lexer.tokens lb in
    let rec go env =
      let open Printf in
        if conf.interactive then
          fprintf out_c "> %!";
        match parse () with
          | None -> ()
          | Some sexp ->
              let env', rst = Eval.eval env sexp in
                begin match rst with
                  | Void -> ()
                  | _ ->
                      if conf.print_result then
                        fprintf out_c "%s\n" (Print.print_value rst)
                end;
                go env';
    in
      Runtime.Fiber.create go (Prim_env.prim_env ());
      let rec receive_exn exn_list =
        let expn =
          Event.sync (Event.receive Runtime.Repl.exn_channel)
        in
          match expn with
            | Normal_exit -> exn_list
            | Dead_lock -> expn :: exn_list
            | _ -> receive_exn (expn :: exn_list)
      in
      let exn_list = L.rev (receive_exn []) in
      let final_exn =
        match exn_list with
          | [] -> Normal_exit
          | [expn] -> expn
          | _ -> (Repl_exn exn_list)
      in
        if final_exn <> Normal_exit then
          (if conf.print_exn then
             prerr_endline (Print.print_exn final_exn);
           raise final_exn)
;;
