{- Funktionale Programmiertechniken -}
{- Exercise 2, Version 1.1, Oktober 2016 -}
{- Thomas Jirout, 1525606 -}

import Data.Char

{-
    Task 1
-}
fac :: Integer -> Integer
fac n
  | n == 0    = 1
  | otherwise = n * fac(n-1)

{- List all factorials from 0 to n -}
facLst :: Integer -> [Integer]
facLst n
    | n < 0 = []
    | otherwise  = take (fromIntegral $ n+1) (map fac $ [0..n])

{- List all factorials from n to 0 -}
factsL :: Integer -> [Integer]
factsL n = reverse . facLst $ n

{-
    Task 2
-}

{-
    extracts a numeral that starts at the beginning of the string
-}
extractNumeral :: String -> String
extractNumeral s = takeWhile isDigit s

{-
    extract all numerals contained in a string into a list
-}
extractNumerals :: String -> [String]
extractNumerals s
    | numeralStart == ""     = []
    | otherwise                 = [extractNumeral numeralStart] ++ extractNumerals nextLetterAfterNumeral
    where   numeralStart = dropWhile isLetter s
            nextLetterAfterNumeral = dropWhile isDigit numeralStart

{-
    Task 3
-}
isPowOf2 :: Int -> (Bool, Int)
isPowOf2 n
    | power == -1   = (False, -1)
    | otherwise     = (True, power)
    where power = halfAndCount n 1

{-
    counts how many times a number can be halved until it becomes 2;
    returns i (2^i = n)
    returns -1 if n could not be halved until n=2 is reached
-}
halfAndCount :: Int -> Int -> Int
halfAndCount n i
    | n < 0     = -1
    | n == 0    = 0
    | n == 2    = i
    | mod == 0  = halfAndCount quot $ i + 1
    | mod /= 0  = -1
    where   halfResult = divMod n 2
            mod = snd(halfResult)
            quot = fst(halfResult)

{-
    calculates the power of two out of a given string numeral,
    returns -1 if the given string is not a numeral or no is no power of two
-}
extractAndReturnPowOf2 :: String -> Int
extractAndReturnPowOf2 s
    | numeralStr /= ""  = snd . isPowOf2 $ read numeralStr :: Int
    | otherwise         = -1
    where numeralStr = extractNumeral s

{-
    convert all given numerals into their log2 represenation
-}
sL2pO2 :: [String] -> [Int]
sL2pO2 s = map extractAndReturnPowOf2 s

curry3 :: ((a, b, c) -> d) -> a -> b -> c -> d
curry3 f a b c = f (a, b, c)

uncurry3 :: (a -> b -> c -> d) -> (a, b, c) -> d
uncurry3 f (a, b, c) = f a b c

curry4 :: ((a, b, c, d) -> e) -> a -> b -> c -> d -> e
curry4 f a b c d = f (a, b, c, d)

uncurry4 :: (a -> b -> c -> d -> e) -> (a, b, c, d) -> e
uncurry4 f (a, b, c, d) = f a b c d
