{-# LANGUAGE OverloadedStrings #-}

module Connector.Database.Main
  ( run
  ) where

import qualified Data.Map.Strict as Map

import Ast
import Control.Monad.State
import Connector.Database.Query

-------------------------
-- Execute Operations
-------------------------

runQuery :: Connection -> Table -> Filter -> Entity -> IO [Entity]
runQuery connection table filter entity = do
  entities <- getRows connection table filter entity
  -- @todo: this adds the immediate parents for the results. I need all the
  -- parents that were used to get to this point. For that I'll have to update
  -- the Entity type so that I keeps the parent entity
  return $ case entities of
    x:xs -> case entity of
      NoEntity -> entities
      _        -> entity:x:xs
    _    -> []

runQuery' :: Connection -> Table -> Filter -> [Entity] -> IO [Entity]
runQuery' connection table filter entities = do
  result <- traverse (runQuery connection table filter) entities
  return $ join result

runQuery'' :: Connection -> Table -> Filter -> IO [Entity] -> IO [Entity]
runQuery'' connection table filter entities = do
  entity <- entities
  runQuery' connection table filter entity

type Operation = (Table, Filter)
type PineValue = IO [Entity]
type PineState = IO [Entity]
exec :: Connection -> [Operation] -> State PineState PineValue
exec _ [] = do
  results <- get
  return results
exec connection ((table, filter):operations) = do
  results <- get
  put (runQuery'' connection table filter results)
  exec connection operations

-- Nothing as the filter, and no results
initState :: IO [Entity]
initState = return [NoEntity]

-- Use test ops instead of the ops specified in arguments.
-- @todo: remove
--
testOps = [("caseFiles", Id 1), ("documents", Desc "Sample")]

run :: Connection -> [Operation] -> IO [Entity]
run connection ops = evalState (exec connection ops) initState

-- Hard coded tests
--
-- run :: Connection -> IO ([Entity])
-- run connection = do
--   caseFiles <- runQuery connection "caseFiles" (Id 1) NoEntity
--   documents <- runQuery connection "documents" NoFilter (head caseFiles)
--   return $ documents
