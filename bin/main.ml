module IC = struct
  type label = int
  type name = string
  type term =
    | Var of name (* variable *)
    | App of term ref * term ref
    | Lam of name * term ref (* ʎx. a *)
    | Sup of label * term ref * term ref (* &l {a, b} *)
    | Dup of label * name * name * term ref * term ref (* !&l { x1, x2 } = a; b *)
    | Era
end
