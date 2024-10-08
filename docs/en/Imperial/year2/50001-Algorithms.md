# lecture1
this lecture would remind us about haskell, lazy/strict evaluation

```haskell
module Intro where
```

goals of the course:

- explore different paradigms
- algorithmic thinking
- analyse performance
- mathematical modeling

```haskell
insert :: Ord a => a -> [a] -> [a]
insert x [] = [x]
insert x (y:ys) = 
  | x <= y    = x : y : ys
  | otherwise = y : insert x ys 
```

let T_insert(n) stand for the time needed to insert n

then

- T_insert(0) = 1
- T_insert(n) = 1 + T_insert(n-1)

so T_insert(n) = n + 1, it is O(n) in time, the list is O(n) in space

```haskell
isort :: Ord a => [a] => [a]
isort [] = []
isort (x:xs) = insert x (isort xs)
-- we first want xs to be sorted, so isort xs
-- we want to insert x to the sorted xs, so insert x (isort xs)
```

- T_isort(0) = 1
- T_isort(n) = 1 + T_insert(n-1) + T_isort(n-1)

so 

$\begin{aligned}
\text{T_isort}(n) &= 1 + \text{T_insert}(n-1) + \text{T_isort}(n-1)\\
&=1 + n + \text{T_isort}(n-1)\\
&= 1+n+(1+n-1) + \text{T_isort}(n-2)\\
&=n + \sum_{i=1}^{n}i\\
&=O(n^2)\end{aligned}$

we create two further functions

```haskell
head :: [a] -> a
head (x:_) = x
```

```haskell
minimum :: Ord a => [a] -> a
minimum xs = head(isort xs)
-- isort sorts the list, the head is the minimum
```

so

```haskell
minimum [3,5,2,1] = head (isort [3,5,2,1])
                  = head (insert 3 (isort [5,2,1]))
                  = head (insert 3 (insert 5 (isort [2,1])))
                  = head (insert 3 (insert 5 (insert 2 (isort [1]))))
                  = head (insert 3 (insert 5 (insert 2 (insert 1 []))))
                  = head (insert 3 (insert 5 (insert 2 (1 : ?))))
                  = head (insert 3 (insert 5 ((1 : ?))))
                  = head (insert 3 (((1 : ?))))
                  = head ((((1 : ?))))
                  = 1
```

minimum looked like $O(n^2)$ but it is $O(n)$

if haskell is a strict language, then minimum is $O(n^2)$

if the algorithm looked at every part of the data, then there is no difference between lazy and strict

if haskell is lazy

```haskell
head (repeat 42) = head (42 : repeat 42) 
                 = 42
```

if haskell is strict

```haskell
head (repeat 42) = head (42 : repeat 42) 
                 = head (42 : 42 : 42 : ...)
```

## Normal Forms
lazy stuff are in WHNF(Weak-Head Normal Form), strict stuff are in NF(Normal Form)

this is usually defined in terms of the lambda calculus

- abstraction: \x -> e
- application: f x
- variables: x

An expression e is in Normal Form if it is not reducable

- \x -> e where e is normal
- x is normal
- f x is normal when f is a variable and both f and x are normal

WHNF is similar but bodies of lambda need not be normal

```\x -> (\y -> y) x```

```x : (\...) 7 xs``` is WHNF ```(:) x ()```

NF:
- 1
- Just 4
- [1,2,3]
- \x -> x+1
- Just
- \f -> f 7(we dont know what f is)

WHNF (all the above and)
- 1 : repeat 1
- \x -> 3 + 4
- Just (3+4)

Expressions(all the above and)
- 3 + 4
- repeeat 1

## Model to evaluate the cost of the algorithm

```haskell
e ::= x          -- variable
    | k          -- constant(0,[],(:),+,*)
    | f e1 .. en -- application
    | if e then e1 else e2 -- conditional
```

since we can do ```f e1 .. en = e``` and ```[x,y,z] = x : y : z : []```

```haskell
insert x xs = 
  if null xs then : []
  else if x <= head xs then x : xs
  else head xs : insert x (tail xs)
```

let ```T(f) x1 .. xn``` is the number of steps it takes to evaluate ```f x1 .. xn```

when f is primitive (+), (*), (:)

- T(f) x1 .. xn = 0
- T(head) xs = 0
- T(f e1 .. en) = T(f) e1 .. en + T(e1) + .. + T(en)
- T(if e then e1 else e2) = T(e) + if e then T(e1) else T(e2)

we have length = if null xs then 0 else 1 + length (tail xs)

T(length xs) = T(length) + T(null) + T(xs) + if null xs then T(0) else T(+) + T(1) + T(length) + ...

Composition:

The cost of 
```
T(f(g(x))) = T(f) (g x) + T(g(x))
           = T(f) (g x) + T(g) x + T(x)
           = T(f) (g x) + T(g) x
```

complexity

functions used to describe complexity comprise of the following

- symbols: x, n, m
- logs
- exp
- constants

complexity functions includes
- $O$
- $\Theta$
- $\Omega$
- $\omega$
- $o$

for f(x) and g(x) check $\lim_{n\to\infty} \frac{f(n)}{g(n)}$ and 0

see https://oi.wiki/basic/complexity/


