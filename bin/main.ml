open LinearLogic

let print_duality name t =
  Printf.printf "%s:\n" name;
  Printf.printf "  Type:  %s\n" (string_of_type t);
  Printf.printf "  Dual:  %s\n" (string_of_type (dual t));
  Printf.printf "  Dual²: %s\n\n" (string_of_type (dual (dual t)))

let () =
  print_endline "=== Linear Logic Type System ===\n";

  print_endline "--- Dualities ---";
  print_duality "Tensor ↔ Par"
    (Tensor (Var "A", Var "B"));

  print_duality "Plus ↔ With"
    (Plus (Var "A", Var "B"));

  print_duality "Of Course ↔ Why Not"
    (OfCourse (Var "A"));

  print_duality "Linear Implication"
    (Lollipop (Var "A", Var "B"));

  print_endline "--- Examples from Book ---";
  Printf.printf "read_file: %s\n" (string_of_type Examples.read_file);
  Printf.printf "serialize: %s\n" (string_of_type Examples.serialize);
  Printf.printf "parse: %s\n" (string_of_type Examples.parse);
  Printf.printf "add: %s\n" (string_of_type Examples.add);

  print_endline "\n--- Involution Property ---";
  let test_type = Tensor (Var "A", Var "B") in
  Printf.printf "Original: %s\n" (string_of_type test_type);
  Printf.printf "Dual:     %s\n" (string_of_type (dual test_type));
  Printf.printf "Dual²:    %s\n" (string_of_type (dual (dual test_type)));
  Printf.printf "Involution holds: %b\n" (dual (dual test_type) = test_type)
