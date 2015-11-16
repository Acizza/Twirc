module Processor
( ProcessType(..)
, UpdateSource
, process
) where

import Control.Concurrent.MVar (MVar, takeMVar)
import Client.Message (parse, Message(..))
import qualified Client.IRC as I (State, process)

data ProcessType =
    IRC String |
    Console String

type UpdateSource = MVar ProcessType

process :: UpdateSource -> I.State -> IO ()
process us state = do
    type' <- takeMVar us
    newS <-
        case type' of
            IRC x -> do
                case parse x of
                    Just x' -> I.process state x'
                    Nothing -> return ()
                return state
            Console x -> do
                putStrLn $ "Console: " ++ x
                return state

    process us newS
