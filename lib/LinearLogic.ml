type linear_type =
  | Tensor of linear_type * linear_type
  | Par of linear_type * linear_type
  | Lollipop of linear_type * linear_type
  | With of linear_type * linear_type
  | Plus of linear_type * linear_type
  | OfCourse of linear_type
  | WhyNot of linear_type
  | Negation of linear_type
  | Unit
  | Bottom
  | Top
  | Zero
  | Var of string

let rec string_of_type = function
  | Tensor (a, b) ->
      Printf.sprintf "(%s ⊗ %s)" (string_of_type a) (string_of_type b)
  | Par (a, b) ->
      Printf.sprintf "(%s ⅋ %s)" (string_of_type a) (string_of_type b)
  | Lollipop (a, b) ->
      Printf.sprintf "(%s ⊸ %s)" (string_of_type a) (string_of_type b)
  | With (a, b) ->
      Printf.sprintf "(%s & %s)" (string_of_type a) (string_of_type b)
  | Plus (a, b) ->
      Printf.sprintf "(%s ⊕ %s)" (string_of_type a) (string_of_type b)
  | OfCourse a ->
      Printf.sprintf "!%s" (string_of_type a)
  | WhyNot a ->
      Printf.sprintf "?%s" (string_of_type a)
  | Negation a ->
      Printf.sprintf "(%s)⊥" (string_of_type a)
  | Unit -> "1"
  | Bottom -> "⊥"
  | Top -> "⊤"
  | Zero -> "0"
  | Var x -> x

let rec dual = function
  | Tensor (a, b) -> Par (dual a, dual b) (* (A ⊗ B)⊥ = A⊥ ⅋ B⊥ *)
  | Par (a, b) -> Tensor (dual a, dual b) (* (A ⅋ B)⊥ = A⊥ ⊗ B⊥ *)
  | With (a, b) -> Plus (dual a, dual b) (* (A & B)⊥ = A⊥ ⊕ B⊥ *)
  | Plus (a, b) -> With (dual a, dual b) (* (A ⊕ B)⊥ = A⊥ & B⊥ *)
  | Lollipop (a, b) -> Tensor (a, dual b) (* (A ⊸ B)⊥ = A ⊗ B⊥ *)
  | OfCourse a -> WhyNot (dual a) (* (!A)⊥ = ?(A⊥) *)
  | WhyNot a -> OfCourse (dual a) (* (?A)⊥ = !(A⊥) *)
  | Negation a -> a (* (A⊥)⊥ = A *)
  | Unit -> Bottom  (* 1⊥ = ⊥ *)
  | Bottom -> Unit  (* ⊥⊥ = 1 *)
  | Top -> Zero (* ⊤⊥ = 0 *)
  | Zero -> Top (* 0⊥ = ⊤ *)
  | Var x -> Negation (Var x) (* x⊥ = (x)⊥ *)

let is_self_dual t =
  dual t = t

module Examples = struct
  (* FileHandle ⊸ Bytes *)
  let read_file =
    Lollipop (Var "FileHandle", Var "Bytes")

  (* (FileHandle ⊗ Bytes) ⊸ Result *)
  let process =
    Lollipop (
      Tensor (Var "FileHandle", Var "Bytes"),
      Var "Result"
    )

  (* Data ⊸ (JSON & XML) *)
  let serialize =
    Lollipop (
      Var "Data",
      With (Var "JSON", Var "XML")
    )

  (* String ⊸ (Error ⊕ Value) *)
  let parse =
    Lollipop (
      Var "String",
      Plus (Var "Error", Var "Value")
    )

  (* !Int ⊸ !Int ⊸ !Int *)
  let add =
    Lollipop (
      OfCourse (Var "Int"),
      Lollipop (
        OfCourse (Var "Int"),
        OfCourse (Var "Int")
      )
    )

  (* Unit ⊸ ?String *)
  let debug_info =
    Lollipop (Unit, WhyNot (Var "String"))

  (* ?Resource ⊸ Unit *)
  let cleanup =
    Lollipop (WhyNot (Var "Resource"), Unit)

  (* (A ⅋ B) ⊸ Result *)
  let concurrent_compute =
    Lollipop (
      Par (Var "A", Var "B"),
      Var "Result"
    )
end
