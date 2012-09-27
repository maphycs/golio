module M = Map.Make(String)

type value =
  | Sexp of sexp
  | Func of func
  | Macro of macro
  | Undefined

and sexp =
  | Number of int
  | Symbol of string
  | String of string
  | Bool of bool
  | List of value list
  | DottedList of value list * value

and func =
  | PrimFunc of string * (value list -> value)
  | UserFunc of func_record

and macro =
  | PrimMacro of string * (env -> value list -> env * value)

and env =
    value ref M.t

and func_record = {
  params : string list;
  vararg : string option;
  body : value list;
  closure : env;
}
;;

let number num =
  Sexp (Number num)
;;
let symbol sym =
  Sexp (Symbol sym)
;;
let string_ str =
  Sexp (String str)
;;
let bool_ bl =
  Sexp (Bool bl)
;;
let list_ lst =
  Sexp (List lst)
;;
let dotted_list lst last =
  Sexp (DottedList (lst, last))
;;

let unpack_sexp value =
  match value with
    | Sexp sexp -> sexp
    | _ -> invalid_arg "unpack_sexp: expected a sexp"
;;
let unpack_num value =
  match unpack_sexp value with
    | Number num -> num
    | _ -> invalid_arg "unpack_num: expected a number"
;;
let unpack_sym value =
  match unpack_sexp value with
    | Symbol sym -> sym
    | _ -> invalid_arg "unpack_sym: expected a symbol"
;;
let unpack_str value =
  match unpack_sexp value with
    | String str -> str
    | _ -> invalid_arg "unpack_str: expected a string"
;;
let unpack_bool value =
  match unpack_sexp value with
    | Bool bl -> bl
    | _ -> invalid_arg "unpack_bool: expected a bool"
;;
let unpack_list value =
  match unpack_sexp value with
    | List lst -> lst
    | _ -> invalid_arg "unpack_list: expected a list"
;;
let unpack_func value =
  match value with
    | Func func -> func
    | _ -> invalid_arg "unpack_func: expected a func"
;;