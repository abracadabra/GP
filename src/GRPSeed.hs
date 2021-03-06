--{-# LANGUAGE Safe #-}
--Best to compile results of this as Safe if the code gen has sufficient freedom.

module GRPSeed
( act
, reprogram
, initial
--, reinforcement
) where

import System.Random
import Data.Maybe (isJust, fromJust)
import Data.List
import GRPCommon
import Language.Haskell.Exts.Parser

reprogram :: [StdGen] -> State -> [String] -> (String, State)
act :: [StdGen] -> State -> Input -> (Output, State)
--reinforcement :: [StdGen] -> State -> Int -> String -> State
--initial :: State

{-
testrun = do
  text <- System.IO.Strict.readFile "./GRPSeed.hs"
  rng <- newStdGen
  let (newcode, _) = reprogram [rng] [] [fromJust $ dropSafetyPrefix text]
  return newcode

t2 = do
  text <- System.IO.Strict.readFile "./GRPSeed.hs"
  let t2 = fromJust $ dropSafetyPrefix text
  let preproc = unwords $ {- Here be mutate -}concat $ intersperse ["\n"] $ map words $ lines t2
  return preproc
-}

--Note: Currently, the generator part is exempt from being modified:
reprogram ( r1 : _ ) state ( source1 : _ ) = let candidates = map ( \ rng -> lexemlisttransform ( preproc source1 ) rng state ) ( infrg r1 ) in (head $ filter ( \ candidate -> ( candidate /= postproc ( preproc source1 ) ) && ( parseable candidate ) ) (map postproc $ filter (\x -> True) candidates), state )
parseable str = let result = parseModule str in wasSuccess result
wasSuccess ( ParseFailed _ _ ) = False
wasSuccess ( ParseOk _ ) = True
preproc str = concat $ intersperse ["\n"] $ map words $ lines str
postproc strs = rmlist ( \ x y -> x == '\n' && y == ' ' ) $ unwords strs
infrg rg = let ( x , y ) = split rg in x : infrg y
rmlist predicate ( x : y : ys ) = if predicate x y then rmlist predicate ( x : ys ) else x : rmlist predicate ( y : ys )
rmlist a xs = xs
initial = [ 10000000 , 20000000 ]
lexemlisttransform [] rng state = []
lexemlisttransform ( lex : lst ) rng state = let ( decision , rng2 ) = next rng :: ( Int , StdGen ) in if decision < ( head initial ) then let ( n , rng3 ) = next rng2 in ( lexems !! ( mod n $ length lexems ) ) : lex : ( lexemlisttransform lst rng3 state) else if decision < ( last initial ) then lexemlisttransform lst rng2 state else lex : ( lexemlisttransform lst rng2 state)

--The Danger Zone starts here. Keep the next line up to date:
safeLines = 51
act rngs state inp = ( (take (div (length inp) 2) inp, drop (div (length inp) 2) inp), state)
