Funktionale Programmiertechniken
Exercise 4, November 2016
Thomas Jirout, 1525606

Initialize data types

> data Tree a = Nil | Node a (Tree a) (Tree a) deriving (Eq,Ord,Show)
> data Order = Up | Down deriving (Eq,Show)

nil: returns a Nil Tree

> nil :: Tree a
> nil = Nil

isNilTree: returns True if given Tree is Nil, False otherwise

> isNilTree :: Tree a -> Bool
> isNilTree Nil = True
> isNilTree t   = False

isNodeTree: opposite of isNilTree

> isNodeTree :: Tree a -> Bool
> isNodeTree Nil = False
> isNodeTree t   = True

leftSubTree, rightSubtree: returns the left/right subtree of a given Tree

> leftSubTree :: Tree a -> Tree a
> leftSubTree Nil = error "Empty Tree as Argument"
> leftSubTree (Node _ left _) = left

> rightSubTree :: Tree a -> Tree a
> rightSubTree Nil = error "Empty Tree as Argument"
> rightSubTree (Node _ _ right) = right

treeValue: returns the value of given node

> treeValue :: Tree a -> a
> treeValue Nil = error "Empty Tree as Argument"
> treeValue (Node a _ _) = a

flatten: returns a list of the elements in a Tree
input tree must be ordered

> flatten :: Ord a => Order -> Tree a -> [a]
> flatten _ Nil = []
> flatten order t@(Node a left right)
>   | isOrderedTree t == False = error "Argument Tree not Ordered"
>   | order == Up   = flatten order left ++ [a] ++ flatten order right
>   | order == Down = flatten order right ++ [a] ++ flatten order left

treeComp: compare current item plus all sub items against a given function
functions that can be passed for example: minimum, maximum

> treeComp :: Ord a => ([a] -> a) -> Tree a -> a
> treeComp _ Nil = error "Input Tree cannot be Nil"
> treeComp f (Node a Nil Nil) = a
> treeComp f (Node a Nil right) = f [a, treeComp f right]
> treeComp f (Node a left Nil) = f [a, treeComp f left]
> treeComp f (Node a left right) = f [a, treeComp f left, treeComp f right]

isOrderedTree: returns True if Tree is ordered, False otherwise
A Tree is ordered if
- max(left) < self < min(right)
- All subtrees are ordered as well

> isOrderedTree :: (Ord a) => Tree a -> Bool
> isOrderedTree Nil                 = True
> isOrderedTree (Node a Nil Nil)    = True
> isOrderedTree (Node a left right)
>   | left  == Nil = (a < treeComp minimum right) && isOrderedTree right
>   | right == Nil = (a > treeComp maximum left) && isOrderedTree left
>   | otherwise =
>        (treeComp maximum left < a) && (a < treeComp minimum right)
>        && isOrderedTree left && isOrderedTree right

isValueOf: true if a is at least once included in the given tree, false otherwise

> isValueOf :: Eq a => a -> Tree a -> Bool
> isValueOf _ Nil = False
> isValueOf a (Node b left right)
>   | a == b       = True
>   | left == Nil   = isValueOf a right
>   | right == Nil  = isValueOf a left
>   | otherwise = isValueOf a left || isValueOf a right

insert: insert a value into a given ordered tree and return the resulting tree

> insert :: Ord a => a -> Tree a -> Tree a
> insert a Nil = (Node a nil nil)
> insert a t@(Node b left right)
>   | isOrderedTree t == False = error "Argument Tree not Ordered"
>   | a > b     = (Node b left (insert a right))
>   | a < b     = (Node b (insert a left) right)
>   | otherwise = t

delete: delete a value of a given ordered tree and return the resulting tree, which is correctly ordered again

> delete :: Ord a => a -> Tree a -> Tree a
> delete a Nil = Nil
> delete a t@(Node b left right)
>   | isOrderedTree t == False  = error "Argument Tree not Ordered"
>   | isValueOf a left          = (Node b (delete a left) right)
>   | isValueOf a right         = (Node b left (delete a right))
>   | a == b && right /= Nil    = (Node (treeComp minimum right) left (delete (treeComp minimum right) right))
>   | a == b && left /= Nil     = (Node (treeComp maximum left) (delete (treeComp maximum left) left) right)
>   | a == b                    = Nil
>   | otherwise = t

maxLength: hops required to reach leaf that is the farthest away from given root tree

> maxLength :: Tree a -> Int
> maxLength Nil = 0
> maxLength t@(Node a left right)
>   | isNilTree left && isNilTree right = 0
>   | ll >= lr              = ll
>   | otherwise             = lr
>   where   ll = 1 + maxLength left
>           lr = 1 + maxLength right

minLength: hops required to reach the nearest leaf of the given root tree

> minLength :: Tree a -> Int
> minLength Nil = 0
> minLength t@(Node a left right)
>   | isNilTree left && isNilTree right = 0
>   | ll <= lr  = 1 + ll
>   | otherwise = 1 + lr
>   where   ll = minLength left
>           lr = minLength right

balancedDegree: the returned Int indicates how balanced the given tree is. the farther away from zero, the more inbalanced the tree is.

> balancedDegree :: Tree a -> Int
> balancedDegree t = abs $ (maxLength t) - (minLength t)
