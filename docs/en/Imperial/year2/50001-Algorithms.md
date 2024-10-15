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

Functions will always have the form `f x1 .. xn`

since we can do ```f e1 .. en = e``` and ```[x,y,z] = x : y : z : []```

```haskell
insert x xs = 
  if null xs then : []
  else if x <= head xs then x : xs
  else head xs : insert x (tail xs)
```

let ```T(f) x1 .. xn``` is the number of steps it takes to evaluate ```f```and````x1 .. xn```

when f is primitive (+), (*), (:)

```haskell
T(x) = 0  -- in other words, variables are free
T(k) = 0  -- in other words, constants are free
-- evaluating an application is the same as evaluating all the arguments,
-- and then the application of `f` to those arguments (as above)
T(f e1 .. en) = T(f) e1 .. en + T(e1) + .. + T(en)
T(if e then e1 else e2) = T(e) + if e then T(e1) else T(e2)
-- evaluating a condition first evaluates the condition, then conditonally
-- evaluates either arm of the conditional.
T(f) x1 .. xn = 1 + T(e)
```

we have 

```haskell
length xs = if null xs then 0 else 1 + length (tail xs)

T(length xs)
= -- by T(f e1 .. en) = T(f) e1 .. en + T(e1) + .. + T(en)
T(length) xs + T(xs)
= -- by T(x) = 0
T(length) xs + 0
= -- by T(f) x1 .. xn = 1 + T(e)
1 + T(if null xs then 0 else 1 + length (tail xs))
= -- by T(if e then e1 else e2) = T(e) + if e then T(e1) else T(e2)
1 + T(null xs) + if null xs then T(0) else T(length (tail xs))
= -- by T(f e1 .. en) = T(f) e1 .. en + T(e1) + .. + T(en)
1 + T(null) xs + T(xs) + if null xs then T(0) else T(length (tail xs))
= -- By T(primitive) = 0, T(x) = 0
1 + 0 + 0 + if null xs then T(0) else T(length (tail xs))
= -- By T(k) = 0
1 + if null xs then 0 else T(length (tail xs))
= -- By T(f e1 .. en) = T(f) e1 .. en + T(e1) + .. + T(en)
1 + if null xs then 0 else T(length) (tail xs) + T(tail xs)
= -- By T(f e1 .. en) = T(f) e1 .. en + T(e1) + .. + T(en)
1 + if null xs then 0 else T(length) (tail xs) + T(tail) xs + T(xs)
= -- By T(primitive) = 0, T(x) = 0
1 + if null xs then 0 else T(length) (tail xs) + 0 + 0
= -- simplify
1 + if null xs then 0 else T(length) (tail xs)
```

T(length xs) = T(length) + T(null) + T(xs) + if null xs then T(0) else T(+) + T(1) + T(length) + ...

Composition:

The cost of 

this is the composition rule

$$\begin{aligned}
T(f(g(x))) &= T(f)\quad(g\quad x) + T(g(x))\\
           &= T(f)\quad(g\quad x) + T(g)\quad x + T(x)\\
           &= T(f)\quad(g\quad x) + T(g)\quad x
\end{aligned}$$


complexity

functions used to describe complexity comprise of the following

- symbols: x, n, m
- logs
- exp
- constants

so define some symbols here

we have two functions f and g

- $f\succ g \iff \lim_{n\to\infty}\frac{f(n)}{g(n)} = 0$
- $f\succcurlyeq g \iff \lim_{n\to\infty}\frac{f(n)}{g(n)} \lt \infty$
- $f\asymp g \iff \lim_{n\to\infty}0<\frac{f(n)}{g(n)}< \infty$
- $f\preccurlyeq g \iff \lim_{n\to\infty}\frac{f(n)}{g(n)} > 0$
- $f\prec g \iff \lim_{n\to\infty}\frac{f(n)}{g(n)} = \infty$

(the symbols are \succ \succcurlyeq \asymp \preccurlyeq \prec)

complexity functions includes

- $O$ : $f(n)\in O(g(n))\iff f\succcurlyeq g$
- $o$ : $f(n)\in O(g(n))\iff f\succ g$
- $\Theta$ : $f(n)\in \Theta(g(n))\iff f\asymp g$
- $\omega$ : $f(n)\in \Omega(g(n))\iff f\prec g$
- $\Omega$ : $f(n)\in \Omega(g(n))\iff f\preccurlyeq g$

(complete this later)

for f(x) and g(x) check $\lim_{n\to\infty} \frac{f(n)}{g(n)}$ and 0

see https://oi.wiki/basic/complexity/




# tutorial 1:
## Exercise 1.1
**Given the following function concatenating two lists**

```haskell
(++) :: [Int] -> [Int] -> [Int]
[] ++ ys = ys
(x:xs) ++ ys = x : (xs ++ ys)
```

**with a recurrence relation T(n,m), approximate the time it takes to compute xs ++ ys for any list xs of length n and ys of length m**

$$\begin{aligned}
T(0, m) &= 1\\
T(n,m) &= 1 + T(n-1, m)\\
  &= 2 + T(n-2, m)\\
  &= k + T(n-k, m) \forall k < n\\
  &= n + T(0,m)\\
  &=n
\end{aligned}$$

## Exercise 1.2
**Consider an alternative strict time analysis function T', define to be the same as T, except T' is refined to have cost 1 instead of 0 on variables, constants and primitive functions, i.e**

$$\begin{aligned}
T'(x) &= 1\\
T'(k) &= 1\\
T'(f) x_1\dots x_n &=1
\end{aligned}$$

**Compute T'(length xs) in terms of T'(length (tail xs))**

$$\begin{aligned}
T'(\text{length xs}) &= T'(\text{length}) + T'(\text{xs})\\
&= 1 + T' (\text{length}) \text{xs}\\
&= 1 + 1 + T'(\text{if null xs then 0 else 1 + length (tail xs)}) & \text{the def of length}\\
&= 2 + T'(\text{null xs}) + \text{if null xs than T'(0) else T'(1 + length (tail xs))}\\
&= 2 + T'(\text{null xs}) + T'(xs) + \text{if null xs than T'(0) else T'(1 + length (tail xs))} & \text{analysis of null}\\
&= 4 + \text{if null xs then T'(0) else T'(1 + length (tail xs))}\\
&= 4 + \text{if null xs then T'(0) else T'(1) + T'(+) + T'(length (tail xs))}\\
&= 4 + \text{if null xs then 1 else 2 + T'(length (tail xs))}\\
\end{aligned}$$

done

```haskell
length [] = 0
length (y:ys) = 1 + (length ys)
```

## 1.3
**Compute the strict running time of T(length (insert x xs)) using the composition rule**

```haskell
insert :: Ord a => a -> [a] -> [a]
insert x [] = [x]
insert x (y:ys) = 
  | x <= y    = x : y : ys
  | otherwise = y : insert x ys 

length [] = 0
length (y:ys) = 1 + (length ys)
```

so T_length is obviously n+1 with n being the length of the list

so T(length (tail xs)) = length xs - 1

note that we computed T_insert(n) = n+1

where n is the length of y:ys

$$\begin{array}{l|l}\text{T(length (insert x xs))} &\\
=\text{T(length) (insert x xs) + T(insert) x xs} & \text{by composition rule}\\\\
=\text{T(if null (insert x xs) then 0 else 1 +}\\\quad\text{ length (tail (insert x xs))) + T(insert) x xs} & \text{by the def of length}\\\\
=\text{T(null (insert x xs)) + }\\\quad\text{if null (insert x xs) then 0 else}\\\quad\text{T(length (tail (insert x xs))) +} & \text{by T(if e then e1 else e2) =}\\\quad\text{T(insert) x xs} & \text{T(e) + if e then T(e1) else T(e2)}\\\\
=\text{T(null) (insert x xs) + T(insert x xs) +}\\\quad\text{ if null (insert x xs) then 0 else} & \text{by T(f e1 .. en) =}\\\quad\text{T(length (tail (insert x xs)))  + T(insert) x xs} & \text{T(f) e1 .. en + T(e1) + .. + T(en)}\\\\
= \text{2 * T(insert) x xs + T(x) + T(xs) +}\\\quad\text{ if null (insert x xs) then 0 else}\\\quad\text{T(length (tail (insert x xs))) } & \text{by T(primitive) = 0, T(null) _ = 0}\\\\
= \text{2 * T(insert) x xs +}\\\quad\text{ if null (insert x xs) then 0 else}\\\quad\text{T(length (tail (insert x xs)))} & \text{by T(primitive) = 0, T(x), T(xs) = 0}\\\\
= \text{2 * T(insert) x xs +}\\\quad\text{ if null (insert x xs) then 0 else}\\\quad\text{T(length) (tail (insert x xs))} + &\text{by T(f e1 .. en) = }\\\quad\text{T(tail (insert x xs))} & \text{T(f) e1 .. en + T(e1) + .. + T(en)}\\\\
= \text{2 * T(insert) x xs +}\\\quad\text{ if null (insert x xs) then 0 else}\\\quad\text{T(length) (tail (insert x xs))} + &\text{by T(f e1 .. en) = }\\\quad\text{T(tail) (insert x xs) + T(insert x xs)}& \text{T(f) e1 .. en + T(e1) + .. + T(en)}\\\\
= \text{2 * T(insert) x xs +}\\\quad\text{ if null (insert x xs) then 0 else}\\\quad\text{T(length) (tail (insert x xs))} + \\\quad\text{T(tail) (insert x xs) + T(insert) x xs +}&\text{by T(f e1 .. en) = }\\\quad\text{T(x) + T(xs)} & \text{T(f) e1 .. en + T(e1) + .. + T(en)}\\\\
= \text{2 * T(insert) x xs +}\\\quad\text{ if null (insert x xs) then 0 else}\\\quad\text{T(length) (tail (insert x xs))} + \\\quad\text{T(tail) (insert x xs) + T(insert) x xs}&\text{by T(primitive) = 0, T(x),T(xs) = 0}\\\\
= \text{3 * T(insert) x xs +}\\\quad\text{ if null (insert x xs) then 0 else}\\\quad\text{T(length) (tail (insert x xs))} + \\\quad\text{T(tail) (insert x xs)} & \text{by cleaning up}\\\\
= \text{3 * T(insert) x xs +}\\\quad\text{ if null (insert x xs) then 0 else}\\\quad\text{T(length) (tail (insert x xs))}& \text{by T(primitive) = 0, T(tail) _ = 0}\\\\
\end{array}$$

## 1.4
**Pattern matching can be added to the expresion language e as follows**

```
e ::= ... | case e of [] -> e;(x:xs) -> e
```

**Give an appropriate definetion of T(case e1 of [] -> e2;(x:xs) -> e3)**

so 
```haskell
e1
  | [] = e2
  | (x : xs) = e3
```

the rest is the same as if then (two if thens)


## 1.5(finally no more T stuff)

**prove formally that**$(n+1)^2\in\Theta(n^2)$**by exhibiting the necessary constants**

$\lim_{n\to\infty}\frac{(n+1)^2}{n^2}\\
=\lim_{n\to\infty}\frac{n^2+2n+1}{n^2}\\
=\lim_{n\to\infty}1 + \frac{2}{n} + \frac{1}{n^2}\\
=1\le\infty$

so by definition

$(n+1)^2\in\Theta(n^2)$

## 1.6(done in class, will add proof afterwards)
**Justify whether wach of the following is true or false**

- $2n^2 + 3n\in\Theta(x^2)$ -> true
- $2n^2 + 3n\in O(n^3)$ -> true
- $n\log n\in O(n\sqrt{n})$ -> true
- $n + \sqrt{n}\in O(\sqrt{n}\log n)$ -> fasle
- $2^{\log n}\in O(n)$ -> true

## 1.7

**Show formally that**$o(g(n))$**is a proper subset of**$O(g(n))$**for any function g using thier definitions**

so consider a arbitrary $f(x)\in o(g(n))$

then by definition

$\lim_{n\to\infty} \frac{f(n)}{g(n)} = 0 \lt\infty$

so then by definition of $O(g(n))$

$f(n)\in O(g(n))\iff \lim_{n\to\infty}\frac{f(n)}{g(n)}\lt \infty$

so obviously $f(n)\in O(g(n))$

as since f(n) is taken arbitrarily, $o(g(n))\subset O(g(n))$


## 1.8
**Explain why there is no definition $\theta(g(n))$ that corresponds to $\Theta(g(n))$ even though there is $o(g(n))$ coressponding to $O(g(n))$ and $\omega(g(n)$ correspond to $\Omega(g(n))$**

so lets take a look at the definitions


- $f\succ g \iff \lim_{n\to\infty}\frac{f(n)}{g(n)} = 0$
- $f\succcurlyeq g \iff \lim_{n\to\infty}\frac{f(n)}{g(n)} \lt \infty$
- $f\asymp g \iff \lim_{n\to\infty}0<\frac{f(n)}{g(n)}< \infty$
- $f\prec g \iff \lim_{n\to\infty}\frac{f(n)}{g(n)} = \infty$
- $f\preccurlyeq g \iff \lim_{n\to\infty}\frac{f(n)}{g(n)} > 0$

(the symbols are \succ \succcurlyeq \asymp \prec \preccurlyeq)

complexity functions includes


- $o$ : $f(n)\in O(g(n))\iff f\succ g$
- $O$ : $f(n)\in O(g(n))\iff f\succcurlyeq g$
- $\Theta$ : $f(n)\in \Theta(g(n))\iff f\asymp g$
- $\omega$ : $f(n)\in \Omega(g(n))\iff f\prec g$
- $\Omega$ : $f(n)\in \Omega(g(n))\iff f\preccurlyeq g$

you could see that the capitalized notation and the lowercase notation corresponds to each other, they only miss a curve line in the expression, but how do you add a curve line to $\asymp$?

also, from o -> O -> $\Theta$ -> $\omega$ -> $\Omega$ you could see that if $g(n)$ is fixed, $f(n)$ actually display a incresing trend, simply no space for $\theta$

# Lecture 2:
This lecture is about different kinds of lists

In haskell, we have the singly-linked lists

```haskell
data [a] where
  [] :: [a]              -- O(1)
  (:) :: a -> [a] -> [a] -- O(1)
```

we also have grammer sugar for list

```haskell
[1,2,3]
-- is the same as
1 : (2 : (3 : []))
```

we want persistent data structures, or stuff we can reuse

so (++)

```haskell
(++) :: [a] -> [a] -> [a]
```

append two lists together

```[1,2,3] ++ [4,5,6] = [1,2,3,4,5,6]```

```haskell
[] ++ [] = []
[] ++ (y:ys) = (y:ys)
(x:xs) ++ ys = x : (xs ++ ys)
```

so this definition goes through all the elements in xs and ys, and destroies ys

rather we can do 

```haskell
[] ++ ys = ys
(x : xs) ++ ys = x : (xs ++ ys) 
```

this definition preserves ys, so it has structual sharing

We have to tear down xs, and we cannot mutate it

time complexity O(n), n = length xs, obviously

```haskell
concat :: [[a]] -> [a]
concat [] = []
concat (xs:xss) = xs ++ concat xss
```

so the time complexity is $O(nm)$ where all the xs has average lenght n and xss has length m

```haskell
foldr :: (a -> b -> b) -> b -> [a] -> b
```

foldr is a recipe for right associative application of the function f to elements of a list and k

```haskell
(:) x ((:) y ((:) z []))

f x (f y (f z k))
```

so

```haskell
foldr f k [] = k
foldr f k (x:xs) = f x (foldr f k xs)
```

```haskell
xs ++ ys = foldr (:) ys xs
concat xss = foldr (++) [] xss
```

we also have foldl which  applies to left associative operators

```haskell
f (f (f k x) y) z
```

```foldr f k``` and ```foldl f k``` do the same thing *extrinsically*

so f needs to be associative and k needs to be a zero

in other words

```haskell
f x k = x
f k x = x
```

The mathematical model of this is a Monoid

```haskell
class Monoid m where
  mempty :: m
  (<>)   :: m -> m -> m
```

so

```
mempty <> x = x
x <> (y <> z) = (x <> y) <> z
```

in this way we can show that

```foldr (<>) mempty = foldl (<>) mempty```

```haskell
instance Monoid Int where
  mempty = 0
  (<>) = (+)
```

or

```haskell
instance Monoid [a] where
  mempty = []
  (<>) = (++)
```

```foldr (++) [] = foldl (++) []```, they do the same thing

Are the complexity of ```concat1 = foldr (++) []``` and ```concat2 = foldl (++) []```

yes and no, if they are the same size then yes, other then no

foldl will keep traversing the early lists again and again

so

```haskell
foldr (++) [] -- O(n)
foldl (++) [] -- O(n^2)
```

Surely this is not a problem, we have Trees

```haskell
data Tree a = Lead a | Fork (Tree a) (Tree a)
```

```haskell
values :: Tree a -> [a]
values (Lead x) = [x]
values (Fork lt rt) = values lt ++ values rt
```

```haskell
t :: Tree Int
t = Fork (Fork (Leaf 1))
               (Leaf 2)
         (Fork (Leaf 3))
               (Leaf 4)
```

what values does is replace forks with ++

```haskell
vs :: [Int]
vs = ([1] ++ [2]) ++ ([3] ++ [4])
```
We have no control here of the associativity of the ++s

the worst case of ++ is O(n^2). we can do better, but we need a different structure


this is the interface for sequencial data-structures
```haskell
class Seq seq where
  nil :: seq
  cons :: a -> seq a -> seq a
  snoc :: seq a -> a -> seq a
  append :: seq a -> seq a -> seq a
  len :: seq a -> Int
```

we will also add two special cases

```haskell
toList :: seq a -> [a]
fromList :: [a] -> seq a
```

We can make a structure adhere to this

```haskell
instance Seq [] where
  nil = []               -- O(1)
  cons = (:)             -- O(1)
  snoc xs x = xs ++ [s]  -- O(n)
  append = (++)          -- O(n)
  len = length           -- O(n

  toList = id            -- O(1)
  fromList = id          -- O(1)
```

Let's make a new sequence

```haskell
data LenList a = LenList Int [a]
```

```haskell
instance Seq LenList where
  nil = LenList 0 []
  cons x (LenList n xs) = LenList (n + 1) (x : xs)
  snoc (LenList n xs) x = LenList (n + 1) (snoc xs x)
  append (LenList n xs) (LenList m ys) = LenList (n + m) (xs ++ ys)
  len (LenList n _) = n -- O(1)

  toList (LenList _ xs) = xs -- O(1)
  fromList xs = LenList (length xs) xs -- O(n)
```

as a side note, there are probably more operations we'd like to support

```haskell
head :: seq a -> a      -- for list O(1)
tail :: seq a -> seq a      -- for list O(1)
init :: seq a -> seq a      -- for list O(1)
last:: seq a -> a      -- for list O(n)
(!!) :: seq a -> Int -> a      -- for list O(n)
```

We'll do this in another lecture

We are interested in a representations of sequences where appending is cheap.

Let's look at function composition

```haskell
(f . g) x = f (g x)
((f . g) . h) x = (f . g) (h x)
                = f (g (h x))

(f . (g . h)) x = f ((g . h) x)
                = f (g (h x))
```

Function composition has a nice property: It does not matter which way round you write it, lets do this to lists

```haskell
xs ++ (ys ++ zs)
=
xs ++ (ys ++ (zs ++ []))
=
(xs ++) ((ys ++) ((zs ++) []))
=
(xs ++) . (ys ++) . (zs ++) [] :: [a]
~
toList ((xs ++) . (ys ++) . (zs ++)) :: [a]
~
toList (fromList xs . fromList ys . fromList zs) :: [a]
```

```haskell
data DList a = DList ([a] -> [a])
```

this is called a difference List

Lets use the aove intuition to start filling the following

```haskell
instance Seq DList where
  toList (DList dxs) = dxs [] -- O(n)
  fromList xs        = DList (xs ++) -- O(1)

  nil               = DList id
```

Early on, we knwo that Lists are monoids

```haskell
[] ++ xs = xs
xs ++ [] = xs
xs ++ (ys ++ zs) = (xs ++ ys) ++ zs
```

```haskell
id . f = f
f . id = f
f . (g . h) = (f . g) . h
```

Functions of type (a -> a) are also monoids. This seems to line up nicely

```haskell
cons x dxs = fromList [x] `append` dxs -- O(?)
           = DList ([x] ++)  `append` dxs
           = DList (x :) `append` dxs
           -- imagine pattern matching here
           = DList ((x :) . dxs)
snoc dxs x = dxs `append` fromList [x] -- O(?)
           = dxs `append` DList (x :)
           -- imagine pattern matching here
           = DList (dxs . (x :))

cons x (DList dxs) = DList ((x :) . dxs) -- O(1)
snoc x (DList dxs) = DList (dxs . (x :)) -- O(1)
```

so now

```haskell
append (DList dxs) (DList dys) = DList (dxs . dys) -- O(1)
```

```haskell
len dxs = length (toList dxs) -- O(2n) ~ O(n)
```

```haskell
head dxs = head (toList dxs) -- O(n)
```

So difference Lists are good at constructing Lists. They are awful at processing

```haskell
values' :: Tree a -> [a]
values' t = toList (go t)
  where go :: Tree a -> DList a
        go (Leaf x) = cons x nil
        go (Fork rt lt) = go (lt) `app end` go rt
```

so The complexity of go ens ip being O(n) in the number of nodes in the tree, n . toList is O(n), m <= n, in the number of leaves in the tree m. values has overall complexity O(n) in the size of the tree

We have seen an asymptotic improvement in the performance of values

```haskell
t :: Tree Int
t = Fork (Fork (Leaf 1))
               (Leaf 2)
         (Fork (Leaf 3))
               (Leaf 4)
```

```haskell
vs = values' t
   = toList (go t)
   = toList (go Fork (Fork (Leaf 1))
                           (Leaf 2)
                     (Fork (Leaf 3))
                           (Leaf 4))
    -- we know that go replaces leaves 
    -- with singletons an forks with appends
   = toList (append (append ([1]))
                       ([2])
                       (append ([3]))
                       ([4]))
   = toList (append (DList ((1 :)))
                       (DList ((2 :)))
                append ((DList ((3 :))))
                       (DList ((4 :))))
   = toList (append (DList ((1 :)))
                       (DList ((2 :)))
                append ((DList ((3 :))))
                       (DList ((4 :))))
   = toList (append )

```

Are difference Lists useful?

In a purefully functional language, haskell, its good, but why haskell, why functional programming

in an impure language like scala, we can do better, we can just add things at the end of a mutable builder. In fact, sometimes toList is O(1) even for those

