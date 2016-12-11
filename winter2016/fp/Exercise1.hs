{- Funktionale Programmiertechniken -}
{- Exercise 1, Version 1.1,  Oktober 2016 -}
{- Thomas Jirout, 1525606 -}

import Data.List as L

fac :: Integer -> Integer
fac n
  | n == 0    = 1
  | otherwise = n * fac(n-1)

-- m = k [k | k = fac c]
facInvImpl :: Integer -> Integer -> Integer -> Integer
facInvImpl m k c
  | k > m || m <= 1   = -1
  | k == m            = c
  | k < m             = facInvImpl m (k*x) x
  where x = c+1

{- task 1 - calculate k for a given m in m = k! -}
facInv :: Integer -> Integer
facInv n = facInvImpl n 1 1

{- task 2 - produces a string with only the digits of the given string remaining -}
extractDigits :: String -> String
extractDigits x =
  let allowed = ['0','1','2','3','4','5','6','7','8','9'] :: [Char]
  in [y | y <- x, elem y allowed]


{- task 3 - extracts numbers of a string and returns numeric representation of resulting digit combination -}
convert :: String -> Integer
convert x
  | digits == "" = 0
  | otherwise    = numRepresentation convertedDigits
  where   digits = extractDigits x
          convertedDigits = charListToIntegerList digits

charListToIntegerList :: [Char] -> [Integer]
charListToIntegerList x = L.map stringToInteger (L.map charToString x)

charToString :: Char -> String
charToString a = [a]

stringToInteger :: String -> Integer
stringToInteger x = read x

numRepresentation :: [Integer] -> Integer
numRepresentation l = numRepresentationImpl (L.reverse l) 0

numRepresentationImpl :: [Integer] -> Int -> Integer
numRepresentationImpl l index
  | index >= L.length l = 0
  | index == 0          = (l !! index) + numRepresentationImpl l (index+1)
  | otherwise           = (l !! index) * (10^index) + numRepresentationImpl l (index+1)

{- task 4 - find left most prime with length n-}
isqrt :: Integer -> Integer
isqrt = floor . sqrt . fromIntegral

isPrime :: Integer -> Bool
isPrime k
  | k < 2       = False
  | otherwise   = L.length [ x | x <- [2..isqrt k], k `mod` x == 0] == 0

isPrimeStr :: String -> Bool
isPrimeStr k
  | digit == ""                 = False
  | stringToInteger digit < 0   = False
  | otherwise                   = (isPrime . stringToInteger) digit
  where digit = extractDigits k

sublist index len xs
  | (L.length xs - index) < len   = ""
  | otherwise                     = L.take (len) (L.drop index xs)

removeZeros :: String -> String
removeZeros s = [x | x <- s, notElem x ['0']]

{- Returns left most prime and the next search string to continue searching -}
findLeftMostPrimeImpl :: String -> Int -> (Integer, String)
findLeftMostPrimeImpl s len
  | len < 1                               = (0, s)
  | L.length leftMostDigitPart == 0       = (0, s)
  | leftMostDigitZero == False && isPrimeStr leftMostDigitPart == True  = (stringToInteger leftMostDigitPart, L.drop 1 s)
  | otherwise                             = findLeftMostPrimeImpl (L.drop 1 s) len
  where   digits = extractDigits s
          leftMostDigitPart = sublist 0 len digits
          leftMostDigitZero = (L.take 1 leftMostDigitPart) == "0" {- Catch case where for example "007" would evaluate as prime of length 3 -}

findLeftMostPrime :: String -> Int -> Integer
findLeftMostPrime s len = fst(findLeftMostPrimeImpl s len)

{- task 5 - find all primes -}
findAllPrimes :: String -> Int -> [Integer]
findAllPrimes s len
  | leftMostPrime == 0  = []
  | otherwise           = [leftMostPrime] ++ findAllPrimes (nextSearchString) len
  where digits = extractDigits s
        leftMostPrimeResult = findLeftMostPrimeImpl digits len
        leftMostPrime = fst(leftMostPrimeResult)
        nextSearchString = snd(leftMostPrimeResult)
