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

the rest is the same as if then

$$\begin{aligned}
\text{T(case e1 of []} \to \text{e2;(x:xs)} \to \text{e3)}\\
 = T(e_1) + \text{if null e1 } \to \text{T(e2)}
\end{aligned}$$

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