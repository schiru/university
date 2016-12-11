{--
    Funktionale Programmiertechniken
    Exercise 7, November 2016
    Thomas Jirout, 1525606
--}

import Prelude hiding (subtract)

data Tree a = Nil | Node a Int (Tree a) (Tree a) deriving (Eq,Ord,Show)

type Multiset a = Tree a
data ThreeValuedBool = TT | FF | Invalid deriving (Eq,Show)
data Order = Up | Down deriving (Eq,Show)


isMultiset :: (Ord a, Show a) => Tree a -> Bool
isMultiset t = isOrderedTree t && minimumOccurence t >= 0

isCanonicalMultiset :: (Ord a, Show a) => Tree a -> Bool
isCanonicalMultiset t = isOrderedTree t && minimumOccurence t >= 1

minimumOccurence :: (Ord a, Show a) => Tree a -> Int
minimumOccurence Nil = 1
minimumOccurence t = treeOccComp minimum t

fixNegativeOccurences :: Tree a -> Tree a
fixNegativeOccurences Nil = Nil
fixNegativeOccurences t@(Node a x l r) =
    (Node a (maximum [0,x]) (fixNegativeOccurences l) (fixNegativeOccurences r))

-- Insert a new value into a search tree,
-- in case of a duplicate, sum the x values
insertNode :: Ord a => Tree a -> Tree a -> Tree a
insertNode new@(Node a xn _ _) Nil = (Node a xn nil nil)
insertNode new@(Node a xn _ _) t@(Node b x left right)
  | isOrderedTree t == False = error "Argument Tree not Ordered"
  | a > b       = (Node b x left (insertNode new right))
  | a < b       = (Node b x (insertNode new left) right)
  | a == b      = (Node b (x + xn) left right)

insert :: Ord a => (a, Int) -> Tree a  -> Tree a
insert new@(a, xn) Nil  = (Node a xn nil nil)
insert new@(a, xn) t@(Node b x left right)
    | isOrderedTree t == False = error "Argument Tree not Ordered"
    | a > b       = (Node b x left (insert new right))
    | a < b       = (Node b x (insert new left) right)
    | a == b      = (Node b (x + xn) left right)

-- Generates a multiset out of a given tree
-- output tree is thus always ordered
-- input tree may be ordered or not
mkMultiset :: (Ord a, Show a) => Tree a -> Multiset a
mkMultiset Nil = Nil
mkMultiset t
    | isOrderedTree t   = fixNegativeOccurences t
    | otherwise         = mkMultiset $ foldr (insert) nil $ flattenAny t

mkCanonicalMultiset :: (Ord a, Show a) => Tree a -> Multiset a
mkCanonicalMultiset Nil = Nil
mkCanonicalMultiset t
    | isCanonicalMultiset ms = ms
    | otherwise              = canonizeMultiset ms
    where ms = mkMultiset t

canonizeMultiset :: (Ord a, Show a) => Multiset a -> Multiset a
canonizeMultiset Nil = Nil
canonizeMultiset ms@(Node a x left right)
    | x == 0    = canonizeMultiset $ delete a ms
    | otherwise = (Node a x (canonizeMultiset left) (canonizeMultiset right))

{- flatten: returns a list of the elements in a Tree
input tree must be ordered -}

flatten :: (Ord a,Show a) => Order -> Multiset a -> [(a,Int)]
flatten _ Nil = []
flatten order t@(Node a x left right)
    | isMultiset t == False = []
    | order == Up   = flatten order left ++ self ++ flatten order right
    | order == Down = flatten order right ++ self ++ flatten order left
    where self = if x > 0 then [(a, x)] else []

-- flatten any tree, regardless if ordered or not
-- traversing in-order
flattenAny :: (Ord a,Show a) => Multiset a -> [(a, Int)]
flattenAny Nil = []
flattenAny t@(Node a x left right) =
    flattenAny left ++ [(a, x)] ++ flattenAny right

isElement :: (Ord a, Show a) => a -> Multiset a -> Int
isElement _ Nil = 0
isElement y t@(Node a x left right)
    | isMultiset t == False = -1
    | y == a                = x
    | isValueOf y left      = isElement y left
    | isValueOf y right     = isElement y right
    | otherwise             = 0

-- tests if ms1 is subset of ms2.
-- a multiset is a subset of another, if every occurrence in a does also occur equally or more often in b
isSubset :: (Ord a, Show a) => Multiset a -> Multiset a -> ThreeValuedBool
isSubset Nil ms2 = TT
isSubset ms1@(Node a x left right) ms2
    | isMultiset ms1 == False || isMultiset ms2 == False = Invalid
    | isElement a ms2 < x = FF
    | isSubset left ms2 == FF = FF
    | isSubset right ms2 == FF = FF
    | otherwise = TT

join :: (Ord a, Show a) => Multiset a -> Multiset a -> Multiset a
join Nil ms2 = if isMultiset ms2 then ms2 else Nil
join ms1@(Node a x left right) ms2
    | isMultiset ms1 == False || isMultiset ms2 == False = Nil
    | otherwise = canonizeMultiset $ fixNegativeOccurences $ join right $ join left $ insertNode ms1 ms2

meet :: (Ord a, Show a) => Multiset a -> Multiset a -> Multiset a
meet Nil _ = Nil
meet _ Nil = Nil
meet ms1@(Node a x left right) ms2@(Node b x2 left2 right2)
    | isMultiset ms1 == False || isMultiset ms2 == False = Nil
    | otherwise =
        -- let resLeft = meetImpl ms1 ms2
        --     resRight = meetImpl ms2 ms1
        -- in  canonizeMultiset $ fixNegativeOccurences $ meetImpl resRight $ meetImpl resLeft resRight
        let allKeys = [x | (x,y) <- flatten Up $ join ms1 ms2]
        in  canonizeMultiset $ fixNegativeOccurences $ meetImpl2 allKeys ms1 ms2

meetImpl :: (Ord a, Show a) => Multiset a -> Multiset a -> Multiset a
-- we always traverse over ms1 and apply meetImpl to the same ms2,
-- thus, even when ms1 is Nil, but ms2 is not, we need to return ms2,
-- although the result would actually be Nil
meetImpl Nil ms2 = ms2
meetImpl _ Nil = Nil
meetImpl ms1@(Node a x left right) ms2
    | isMultiset ms1 == False || isMultiset ms2 == False = Nil
    | otherwise = let newOccurence = minimum [x, isElement a ms2]
        in meetImpl right $ meetImpl left $ updateOccurrence (a, newOccurence) ms2

-- takes a list of all keys that are in the multiset of a and b
meetImpl2 :: (Ord a, Show a) => [a] -> Multiset a -> Multiset a -> Multiset a
meetImpl2 [] _ _ = Nil
meetImpl2 s _ Nil = Nil
meetImpl2 s Nil _ = Nil
meetImpl2 (s:sn) a b
    | sn == [] = insert new Nil
    | otherwise = insert new $ meetImpl2 sn a b
    where   countA = isElement s a
            countB = isElement s b
            new = (s, minimum [countA, countB])

updateOccurrence :: (Eq a, Ord a, Show a) => (a, Int) -> Multiset a -> Multiset a
updateOccurrence (a, 0) t   = delete a t
updateOccurrence (a, x) t@(Node b xn left right)
    | a == b                = (Node a x left right)
    | isElement a t == 0    = insert (a, x) t
    | isElement a left /= 0 = (Node b xn (updateOccurrence (a, x) left) right)
    | isElement a right /= 0 = (Node b xn left (updateOccurrence (a, x) right))


-- this function applies ms2 to ms1 (result = ms1 - (every element of ms2))
-- thus, only ms2 is being traversed
subtract :: (Ord a, Show a) => Multiset a -> Multiset a -> Multiset a
subtract ms1 Nil = ms1
subtract Nil _ = Nil
subtract ms1 ms2@(Node a x left right)
    | isMultiset ms1 == False || isMultiset ms2 == False = Nil
    | otherwise = let newOccurence = maximum [0, (isElement a ms1) - x]
        in canonizeMultiset $ fixNegativeOccurences $ subtract (subtract (updateOccurrence (a, newOccurence) ms1) left) right

-- extra functions

treeComp :: Ord a => ([a] -> a) -> Tree a -> a
treeComp _ Nil = error "Input Tree cannot be Nil"
treeComp f (Node a _ Nil Nil) = a
treeComp f (Node a _ Nil right) = f [a, treeComp f right]
treeComp f (Node a _ left Nil) = f [a, treeComp f left]
treeComp f (Node a _ left right) = f [a, treeComp f left, treeComp f right]

treeOccComp :: ([Int] -> Int) -> Tree a -> Int
treeOccComp _ Nil = error "Input Tree cannot be Nil"
treeOccComp f (Node _ x Nil Nil) = x
treeOccComp f (Node _ x Nil right) = f [x, treeOccComp f right]
treeOccComp f (Node _ x left Nil) = f [x, treeOccComp f left]
treeOccComp f (Node _ x left right) = f [x, treeOccComp f left, treeOccComp f right]

{- isOrderedTree: returns True if Tree is ordered, False otherwise
A Tree is ordered if
- max(left) < self < min(right)
- All subtrees are ordered as well -}

nil :: Tree a
nil = Nil

isOrderedTree :: (Ord a) => Tree a -> Bool
isOrderedTree Nil                 = True
isOrderedTree (Node a _ Nil Nil)    = True
isOrderedTree (Node a _ left right)
  | left  == Nil = (a < treeComp minimum right) && isOrderedTree right
  | right == Nil = (a > treeComp maximum left) && isOrderedTree left
  | otherwise =
       (treeComp maximum left < a) && (a < treeComp minimum right)
       && isOrderedTree left && isOrderedTree right

-- delete: delete a value of a given ordered tree and return the resulting tree, which is correctly ordered again


-- DOES NOT WORK THAT WAY because treeComp minimum _ returns only value, should return int-value as well in order to create new shifted node
delete :: (Ord a, Show a) => a -> Tree a -> Tree a
delete a Nil = Nil
delete a t@(Node b x left right)
  | isOrderedTree t == False  = error "Argument Tree not Ordered"
  | isValueOf a left          = (Node b x (delete a left) right)
  | isValueOf a right         = (Node b x left (delete a right))
  | a == b && right /= Nil    =
      let repl = (treeComp minimum right)
          occ = isElement repl right
           in (Node repl occ left (delete repl right))
  | a == b && left /= Nil     =
      let repl = (treeComp maximum left)
          occ = isElement repl left
           in (Node repl occ (delete repl left) right)
  | a == b                    = Nil
  | otherwise = t

--  isValueOf: true if a is at least once included in the given tree, false otherwise
isValueOf :: Eq a => a -> Tree a -> Bool
isValueOf _ Nil = False
isValueOf a (Node b _ left right)
  | a == b       = True
  | left == Nil   = isValueOf a right
  | right == Nil  = isValueOf a left
  | otherwise = isValueOf a left || isValueOf a right
