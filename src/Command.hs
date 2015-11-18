module Command (process) where

import Control.Monad (foldM)
import Data.List (find)
import Text.Printf (printf)
import IRC.Display (printCC)
import IRC.Client (State(..), joinChannel, leaveChannel, sendMessage)

type Name = String
type Usage = String
type NumArgs = Int
type Arguments = [String]
type Action = State -> Arguments -> IO State

type Command = (Name, Usage, NumArgs, Action)

commands :: [Command]
commands = [
    ("join", "<channels>", 1, joinCmd),
    ("leave", "<channels>", 1, leaveCmd),
    ("send", "<channel> <message>", 2, sendCmd),
    ("mods", "<channel>", 1, modsCmd),
    ("channels", "", 0, channelsCmd),
    ("leaveall", "", 0, leaveallCmd)]

-- Start of command implementations

joinCmd :: Action
joinCmd = foldM (flip joinChannel)

leaveCmd :: Action
leaveCmd = foldM (flip leaveChannel)

sendCmd :: Action
sendCmd s (chan:msg) = do
    sendMessage chan (unwords msg) s
    return s
sendCmd s _ = return s

modsCmd :: Action
modsCmd s (chan:_) = do
    mapM_ ((\x -> printCC $ "~r~" ++ x ++ "\n") . snd)
        $ filter (\x -> fst x == chan)
        $ moderators s
    return s
modsCmd s _ = return s

channelsCmd :: Action
channelsCmd s _ = do
    mapM_ (\x -> printCC $ "~r~" ++ x ++ "\n")
        $ channels s
    return s

leaveallCmd :: Action
leaveallCmd s _ = foldM (flip leaveChannel) s $ channels s

-- End of command implementations

printCommands :: IO ()
printCommands =
    mapM_ (\(name, usage, _, _) ->
        printCC $ printf "~r~%s: ~w~%s\n" name usage)
        commands

findCommand :: Name -> Maybe Command
findCommand name = find (\(n, _, _, _) -> n == name) commands

executeCommand :: Name -> Arguments -> State -> Either String (IO State)
executeCommand name args state =
    case findCommand name of
        Just (_, usage, nArgs, f) ->
            if nArgs > length args
            then Left $ printf $ "Usage: " ++ usage
            else Right $ f state args
        Nothing -> Left $ "Command not found: " ++ name

process :: State -> String -> Either String (IO State)
process state = match . words
    where
        match ("commands":_) =
            Right $ do
                printCommands
                return state
        match (cmd:args) = executeCommand cmd args state
        match [] = Left "No input"
