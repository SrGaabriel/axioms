# 🔀 axioms

An [Interaction-Calculus](https://github.com/VictorTaelin/Interaction-Calculus) OCaml implementation and exploration of Interaction Calculus and related structures, with a structured journey through the theory that underpins it.

Thanks to Victor Taelin and [HigherOrderCo](https://higherorderco.com/) for creating the original Interaction-Calculus project!

# 📃 Book

Below are some notes I took while studying the Interaction-Calculus model of computation. Those will be later compiled into a collection of articles or even (possibly? 😅) a book.

## Linear Logic

### Why?

Jean-Yves Girard introduced Linear Logic in 1987 as a refinement of classical logic that emphasizes the concept of resource management.

This is important to us because in programming and in the real world, resources are limited and must be used wisely.

If we analyze through the Curry-Howard correspondence where functions are proofs and types are propositions, there are three models of logic that we can consider when building a programming language:
1. **Classical Logic**: In this model, we can use resources (or assumptions) as many times as we want. This is like having an infinite supply of resources, which is not realistic in many scenarios. This is exactly how most traditional programming languages work. But classical logic also relies on law of excluded middle (A ∨ ¬A) and double negation elimination (¬¬A ⇒ A), which don't have a computational meaning (since in programming terms, you can't get a value of A just because you know that A exists). So while it gives programmers maximal freedom, it provides no guarantees about resource usage and offers weaker connections between mathematics and computation.

2. **Intuitionistic Logic**: This solves classical's logic problems by removing the law of excluded middle and double negation elimination. In intuitionistic logic, we can still duplicate and discard resources, but we have to constructively prove the existence of resources. This means that if we claim that a resource exists, we must provide a way to construct it. This model is more aligned with constructive mathematics and provides a better foundation for programming languages that emphasize correctness and proof, since proving A, in the Curry-Howard correspondence, means to simply provide a value of type A. However, it still allows for infinite duplication and discarding of resources, which can lead to inefficiencies and potential misuse of resources.

3. **Linear Logic**: This is the most restrictive model. In linear logic, we must use each resource exactly once. This means we cannot duplicate or discard resources, which forces us to be more careful with how we manage them. This gives us precise control over resource usage, making it ideal for scenarios where resources are limited or need to be managed carefully, such as in concurrent, parallel and system programming.

So in fact, there are really only two options, going classical is out of question. Most languages that embrace the Curry-Howard correspondence are based on intuitionistic logic (like K Lean, Coq, Agda, Idris, etc.), while a few languages (like Rust) embrace linear logic to provide stronger guarantees about resource usage.

For instance, consider programming in a language like Lean with the Curry-Howard correspondence. You have a variable x of type A representing a scarce resource—perhaps:

* A file handle that must be closed exactly once
* A memory buffer that must be deallocated exactly once
* A cryptographic key that must not be duplicated
* A database transaction that must be committed or rolled back, but not both-critical 

You're tasked with writing a performance-critical function. In classical or intuitionistic logic, the type system can't prevent you from:

* Using x multiple times when you should only use it once (duplication)
* Forgetting to use x at all (discarding)
* Using x in two different branches without ensuring mutual exclusion

The type A → B says "given an A, I can produce a B," but notice how it doesn't specify whether the A is consumed in the process, or whether you can do that same operation multiple times.

Therefore, in a performance-critical context, you might inadvertently introduce bugs or inefficiencies by mismanaging the resource represented by x.

### Linear Connectives

To solve the problems of classical and intuitionistic logic, linear logic introduces several new operators:

#### ⊸ (Linear Implication)

In linear logic, the implication A ⊸ B means that given a resource of type A, you can produce a resource of type B, but you must consume the A in the process.

Exactly what we wanted for our performance-critical function! This way, the type system enforces that you cannot duplicate or discard resources, ensuring that you manage them correctly.

#### ⊗ (Tensor Product)

The tensor product A ⊗ B represents a combination of two resources A and B that must both be used exactly once.

This is similar to a tuple in programming, where you have two values that you must use together.

#### & (With)

The with operator A & B represents a choice between two resources A and B, where you must choose one to use exactly once. This might be confusing because it might sound like linear logic assumes the existence of an external agent that makes choices for the proof to proceed. 

But in reality, in programming terms, this is exactly like a conditional statement (if-else) where only branch executes!

Therefore, in a program, you have A and B ready for taking (like two branches of an if-else), but the caller/environment/runtime will decide which one to actually use.

#### ⊕ (Plus)

The plus operator A ⊕ B represents a situation where you have either resource A or resource B, but you don't know which.

Think of it like a union type in programming, where a value can be one of several types. So for ex `Either A B`, `Result A B`, etc. In those cases, you have either A or B, but you don't know which until runtime. Very similar to a call to `Either.Left` or `Either.Right`.

#### ! (Of Course)

The definition of !A (read as "of course A") is "you can use A as many times as you want".

This is useful for our programming language because primitives (like integers, booleans, etc.) can be duplicated and discarded freely without worrying about resource management. 

#### ? (Why Not)

The definition of ?A (read as "why not A") is "you can choose to not use A".

This is useful for values that are optional or can be ignored without affecting the correctness of the program and that don't rely on optimal resource management.

#### ⅋ (par)

The par operator A ⅋ B represents a situation where you will eventually provide both A and B, but they can be produced/consumed in any order or even simultaneously. Unlike A ⊗ B which packages both resources together as a synchronous pair, A ⅋ B allows for asynchronous or interleaved provision of the two resources.

Think of it as the difference between:

A ⊗ B: "Here's a package containing both A and B" (synchronous)
A ⅋ B: "I'll give you A and B, but possibly at different times" (asynchronous)

You might think "well how do I make use of that relationship then, if they can be provided in any order?". And indeed, this is a more subtle concept in linear logic. The par operator is often used in the context of concurrent or parallel computations, where you might have two processes that can run independently and provide their results at different times. The key concept is: you can be assured that both computations will eventually complete, but you don't have to wait for one to finish before starting the other.

#### ⊥ (negation)

This is the most important connector in linear logic. It represents the concept of "the other side" or, more specifically, the opposite port or complementary interface to a.

Think of it like:
* A socket: A⊥ is a plug
* A producer: A⊥ is a consumer
* An output: A⊥ is an input
* A question: A⊥ is an answer

Funnily enough, in linear logic A⊥⊥ = A, just like in classical logic! But the interpretation is different. In classical logic, ¬¬A = A means "if A is not false, then A is true". In linear logic, A⊥⊥ = A means "the dual of the dual of A is A again", which aligns with the idea of ports and interfaces.

Therefore, A ⊸ B = A⊥ ⅋ B:
```
A ⊸ B: "I consume an A and produce a B"
A⊥ ⅋ B: "I have an input for A and an output for B (available asynchronously)"
```

This is saying: a function is just two ports - one that accepts A (which is A⊥) and one that provides B.

In programming: 
```
A = output port
A⊥ = input port (dual of output)
(A⊥)⊥ = output port (dual of input) = A again
```

This is perfectly constructive because it's just about which side of the wire you're on.

This leads to something like this:

∃x.A ≡ ¬(∀x.¬A)

In classical logic, this is weird because ∃x.A means "there exists an x such that A is true", while ¬(∀x.¬A) means "it's not the case that for all x fail A".

But in linear logic, both sides are equally constructive:

```
∃x.A = "I will provide some specific x and an A"
(∀x.A⊥)⊥ = "I accept a consumer that handles any x with A⊥" (dual)
```

> Quick note: in the Curry-Howard correspondence, ∃x is like an existential type that can be fulfilled by some specific value, while ∀x is like a polymorphic type that can handle any value of type x. So for ex, for a function `id : a -> a` means `∀a. a ⊸ a` in linear logic (for any type a, given an a, you can produce an a). If we replaced that with `∃a. a ⊸ a`, it would mean "there exists some specific type a such that given an a, you can produce an a", which is less useful in programming, since this would lead to me being able to produce `id : a -> a = "42" for some specific type a = Int, which is not what we want.

**Classical negation (¬A):**

* Negates all possible uses of A
* Negates an unspecified number of A's
* Like saying "it's impossible to prove A no matter how many times you try"
* Non-constructive

```
∃x.A: "I have an x that makes A true" (constructive)
¬(∀x.¬A): "It's not impossible" (weak, non-constructive)
```

**Linear negation (A⊥):**

* Negates one specific use of A
* It's the complementary port for one interaction
* Like saying "here's exactly what will react with one A"
* Constructive! Yay!

```
∃x.A: "I will choose some x and provide A[x]"
(∀x.A⊥)⊥: "I accept any consumer that can handle A[x] for any x I might choose"
```

These are dual perspectives on the same interaction! The ∃ side chooses which x, the ∀⊥ side must handle whatever x is chosen.

**TL;DR:**

In linear logic, negation A⊥ isn't about "proving A is false". It's more about having the complementary interface to A, which makes negation involutive ((A⊥)⊥ = A) in a completely constructive way: flipping perspective twice returns you to the original. In interaction nets, this becomes concrete: negation is just port polarity, and wires connect ports of opposite polarity.

#### Dualities

Linear logic's beauty lies in its dualities. That is, many concepts have a complementary counterpart that flips their meaning:

- ⊗ (tensor) ↔ ⅋ (par): synchronous vs asynchronous combination (both now vs both eventually)
- ⊕ (plus) ↔ & (with): internal vs external choice (you encode an ADT vs you match on it)
- ! (of course) ↔ ? (why not): unlimited use vs optional use (use as many times vs use zero or one time)

#### Example

```
// Linear function: consume a file handle, return bytes
read_file: FileHandle ⊸ Bytes

// Tensor: must use both handle and bytes
process: (FileHandle ⊗ Bytes) ⊸ Result

// With: caller chooses JSON or XML output
serialize: Data ⊸ (JSON & XML)

// Plus: function might return error or success
parse: String ⊸ (Error ⊕ Value)

// Of course: integers can be reused freely
add: !Int ⊸ !Int ⊸ !Int

// Why not: you may ignore the returned debug info
debug_info: Unit ⊸ ?String

// Why not: optional cleanup that might be skipped
cleanup: ?Resource ⊸ Unit  // can ignore the resource if not needed

// Par: two computations that can run concurrently
concurrent_compute: (A ⅋ B) ⊸ Result
```

###
