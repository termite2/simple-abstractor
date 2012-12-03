module Resolve where

import qualified Data.Map as Map
import Data.Map (Map)
import Data.Traversable

import AST
import Analysis
import Predicate

resolve :: Map String (VarAbsType, Section) -> CtrlExpr String (Either String Int) -> Either String (CtrlExpr String (Either VarInfo Int))
resolve mp = traverse func 
    where
    func lit = case lit of 
        Left str -> case Map.lookup str mp of
            Nothing          -> Left  $ "Var doesn't exist: " ++ str
            Just (typ, sect) -> Right $ Left $ VarInfo str typ sect
        Right x -> Right $ Right x

doDecls :: [Decl] -> [Decl] -> Map String (VarAbsType, Section)
doDecls sd ld = Map.union (Map.fromList $ concatMap (go StateSection) sd) (Map.fromList $ concatMap (go LabelSection) ld)
    where
    go sect (Decl vars typ) = map go' vars
        where
        go' var = (var, (typ, sect))