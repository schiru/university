Funktionale Programmiertechniken
Exercise 3, Version 1.1, November 2016
Thomas Jirout, 1525606

Defining two new data types: Digits and Numeral

> data Digit = Zero | One | Two deriving (Eq,Enum,Show)
> type Digits = [Digit]
> data Sign = Pos | Neg deriving (Eq,Show) -- Pos for positive, Neg for negative
> newtype Numeral = Num (Sign,Digits) deriving (Eq,Show)

-- Task 1 --

canonize: strip all leading zeros from numeral

> canonize :: Numeral -> Numeral
> canonize (Num (_, []))      = error "Invalid Argument"
> canonize (Num (sgn, first:rest))
>     | first == Zero && length rest > 0    = canonize (Num (sgn, rest))
>     | first == Zero && length rest == 0   = (Num (Pos, [Zero]))
>     | otherwise                           = (Num (sgn, first:rest))


> canonizeDigits :: Digits -> Digits
> canonizeDigits []        = [Zero]
> canonizeDigits (first:rest)
>     | first == Zero        = canonizeDigits rest
>     | otherwise            = first:rest


> int2digit :: Integer -> Digit
> int2digit n
>     | modulo == 2    = Two
>     | modulo == 1    = One
>     | otherwise      = Zero
>    where modulo = n `mod` 3

> int2digits :: Integer -> Digits
> int2digits 0 = []
> int2digits n = int2digits (n `div` 3) ++ [int2digit n]

int2num: Convert Integer to Numeral (base 3)

> int2num :: Integer -> Numeral
> int2num n
>     | n >= 0  = Num (Pos, d)
>     | n < 0   = Num (Neg, d)
>    where d = canonizeDigits $ int2digits $ abs n

d2i: Digit to int

> d2i :: Digit -> Integer
> d2i Two     = 2
> d2i One     = 1
> d2i Zero    = 0

s2m: Convert sign to integer multiplier:

> s2m :: Sign -> Integer
> s2m Pos = 1
> s2m Neg = -1

num2int: Convert Numeral to it's Integer representation

> num2int :: Numeral -> Integer
> num2int (Num (sgn, digits))
>     | length digits == 0   = error "Invalid Argument"
>     | length rest == 0     = sign * currentConversion
>     | length rest > 0      = (sign * currentConversion) + nextConversion
>     where  sign               = s2m sgn
>            firstInt           = d2i (head digits)
>            rest				= drop 1 digits
>            currentConversion  = firstInt * (3^(length rest))
>            nextConversion     = num2int (Num (sgn, rest))

-- Task 2 --

incDigit, increment the given digit by one.
Result: Tupel ((digit) new digit, (bool) true if overflow happened)

> incDigit :: Digit -> (Digit, Bool)
> incDigit digit
>   | digit == Two   = (Zero, True)
>   | digit == One   = (Two, False)
>   | digit == Zero  = (One, False)

decDigit, like incDigits, but decrements

> decDigit :: Digit -> (Digit, Bool)
> decDigit digit
>   | digit == Two   = (One, False)
>   | digit == One   = (Zero, False)
>   | digit == Zero  = (Two, True)


incDigitReversed, increments digits
expects the input digits to be reversed (lsb is left, msb is right)
helper function for incDigits

> incDigitsReversed :: Digits -> Digits
> incDigitsReversed digits
>    | length digits == 0       = [One]
>    | overflow == False        = [newDigit] ++ rest
>    | overflow == True         = [newDigit] ++ incDigitsReversed rest
>    where first = take 1 digits
>          rest = drop 1 digits
>          incResult   = incDigit (first !! 0)
>          newDigit    = fst incResult
>          overflow    = snd incResult

incDigits: increments digits by one (base 3)
digits param expected to be canonized
output is canonized

> incDigits :: Digits -> Digits
> incDigits digits = (canonizeDigits . reverse . incDigitsReversed . reverse) digits

decDigitsReversed, similar to incDigitsReverset,
the only difference is, that a call of decDigitsReversed [] results in []
instead of incDigitsReversed [] = [One]

> decDigitsReversed :: Digits -> Digits
> decDigitsReversed digits
>    | length digits == 0       = []
>    | overflow == False        = [newDigit] ++ rest
>    | overflow == True         = [newDigit] ++ decDigitsReversed rest
>    where first = take 1 digits
>          rest = drop 1 digits
>          decResult   = decDigit (first !! 0)
>          newDigit    = fst decResult
>          overflow    = snd decResult

decDigits: similar to incDigits
input expected to be canonized,
output is canonized

> decDigits :: Digits -> Digits
> decDigits digits = (canonizeDigits . reverse . decDigitsReversed . reverse) digits

decDigit, decrease the given digit by one.
Result: Tupel ((digit) new digit, (bool) true if overflow happened)

inc, increment the given numeral by one
input must be canonized (=> 0 is expected to be Pos, [Zero])
output is canonized

> incCanonized :: Numeral -> Numeral
> incCanonized (Num (sgn, digits))
>   | sgn == Pos            = canonize (Num (Pos, incDigits digits))
>   | sgn == Neg            = canonize (Num (Neg, decDigits digits))

> inc :: Numeral -> Numeral
> inc n = (incCanonized . canonize) n

dec, decrement the given numeral by one
input must be canonized (=> 0 is expected to be Pos, [Zero])
output is canonized

> decCanonized :: Numeral -> Numeral
> decCanonized (Num (sgn, digits))
>   | sgn == Neg || digits == [Zero] = canonize (Num (Neg, incDigits digits))
>   | sgn == Pos                     = canonize (Num (Pos, decDigits digits))

> dec :: Numeral -> Numeral
> dec n = (decCanonized . canonize) n


-- Task 3 --

> numAbs :: Numeral -> Numeral
> numAbs (Num (_, digits))  = (Num (Pos, digits))

> numNeg :: Numeral -> Numeral
> numNeg (Num (_, digits))  = (Num (Neg, digits))

> numAdd :: Numeral -> Numeral -> Numeral
> numAdd n1@(Num (sig1, d1)) n2@(Num (sig2, d2))
>   | d2 == [Zero]  = canonize n1
>   | sig2 == Pos   = numAdd (inc n1) (dec n2)
>   | sig2 == Neg   = numAdd (dec n1) (inc n2)

> numMult :: Numeral -> Numeral -> Numeral
> numMult n1@(Num (sig1, d1)) n2@(Num (sig2, d2))
>   | d2 == [One] && sig1 == sig2 = canonize (Num (Pos, d1))
>   | d2 == [One] && sig1 /= sig2 = canonize (Num (Neg, d1))
>   | d2 == [Zero] || d1 == [Zero] = (Num (Pos, [Zero]))
>   | sig1 == sig2   = numAdd (numAbs n1) $ numMult (numAbs n1) (dec (numAbs n2))
>   | sig1 /= sig2   = numNeg $  numMult (numAbs n1) (numAbs n2)

-- Task 4 --

> curryFlip :: ((a, b) -> c) -> (b -> (a -> c))
> curryFlip = flip . curry

> uncurryFlip :: (a -> (b -> c)) -> ((b, a) -> c)
> uncurryFlip = uncurry . flip

> pairFlip :: ((a, b) -> c) -> ((b, a) -> c)
> pairFlip = uncurry . flip . curry
