import Data.List (maximumBy)
import Data.Array

tabulate :: Ix i => (i,i) -> (i -> a) -> Array i a
tabulate (u,v) f = array (u,v) [ (i, f i) | i <- range (u, v)]

-- 3.9
maximise :: [Int] -> Int
maximise xs = maxIndex
  where 
    total = sum xs
    sds = scanl (\x y -> x + 2*y) (-total) xs
    maxIndex = snd $ maximumBy (\(a, _) (b, _) -> compare a b) indexedSds
    indexedSds = zip sds [0..]  -- Pair each value with its index

splitDiff :: [Int] -> Int -> Int
splitDiff xs i = sum lhs - sum rhs
  where
    (lhs, rhs) = splitAt i xs

-- 3.10
fixer :: ((Int -> a) -> (Int -> a)) -> Int -> a
fixer f i = table ! i
  where table = tabulate (0,i) memo
        memo :: Int -> Int
        memo i = (table ! (i-1)) + (table ! (i-2))

fib :: Int -> Int
fib = fixer go