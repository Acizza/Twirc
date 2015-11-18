module IRC.Message
( Channel
, Username
, Result(..)
, Message(..)
, parse
) where

import Data.List.Split (splitOn)
import Text.Printf (printf)

type Channel = String
type Username = String
type Reason = String

data Result = Success Username | Failure Reason
    deriving (Show)

data Message =
    Message Channel Username String |
    Join Channel Username |
    Leave Channel Username |
    Ping String |
    Login Result

instance Show Message where
    show (Message ch uname msg)
        | ch == uname = printf "~w~[B] ~g~<%s> ~c~%s~w~||: %s" ch uname msg
        | otherwise   = printf "~g~<%s> ~c~%s~w~||: %s" ch uname msg
    show (Join ch uname)         = printf "~g~<%s> ~c~%s ~m~||joined" ch uname
    show (Leave ch uname)        = printf "~g~<%s> ~c~%s ~m~||left" ch uname
    show (Ping _)                = ""
    show (Login (Success uname)) = printf "~w~Logged in as ~m~||%s" uname
    show (Login (Failure rsn))   = printf "~r~Login failed: ~m~||%s" rsn

-- Safe version of !!
(!!!) :: [a] -> Int -> Maybe a
(!!!) list idx
    | idx >= length list = Nothing
    | otherwise          = Just $ list !! idx

getCode :: [String] -> Maybe String
getCode ("PING":_) = Just "PING"
getCode (_:code:_) = Just code
getCode _          = Nothing

parse :: String -> Maybe Message
parse str =
    code >>= \c ->
        case c of
            "PRIVMSG" -> Just $ Message channel username (tail . dropWhile (/=':') . tail $ str)
            "JOIN"    -> Just $ Join channel username
            "PART"    -> Just $ Leave channel username
            "PING"    -> Just $ Ping $ drop (length "PING ") str
            "004"     -> Just $ Login (Success $ sections !! 2)
            "NOTICE"  -> Just $ Login (Failure $ splitOn " :" str !! 1)
            _ -> Nothing
    where
        sections = words str
        code = getCode sections
        username = maybe "ERROR" (tail . takeWhile (/='!')) (sections !!! 0)
        channel = maybe "ERROR" tail (sections !!! 2)
