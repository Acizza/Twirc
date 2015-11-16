module Main where

import Control.Concurrent (forkIO)
import Control.Concurrent.MVar (putMVar, newEmptyMVar)
import Control.Exception (bracket)
import Control.Monad (forever, unless)
import System.IO
import Client.Message (Message(..), Username)
import Processor (ProcessType(..), UpdateSource, process)
import qualified Client.IRC as I

processNetwork :: UpdateSource -> Handle -> IO ()
processNetwork us handle = do
    eof <- hIsEOF handle
    unless eof $ do
        line <- hGetLine handle
        unless (null line) $ putMVar us (IRC line)
        processNetwork us handle

initClient :: UpdateSource -> I.State -> Username -> I.Oauth -> IO I.State
initClient us state username oauth = do
    h <- I.login username oauth (I.connection state)
    s <- I.joinChannel "" state
    forkIO $ processNetwork us h
    return s

processConsole :: UpdateSource -> IO ()
processConsole us = do
    line <- getLine
    putMVar us (Console line)
    processConsole us

main :: IO ()
main = do
    us <- newEmptyMVar
    bracket (I.connect "irc.twitch.tv" 6667) hClose $ \h -> do
        state <-
            let iniState = I.State {
                I.connection = h,
                I.channels   = []
            }
            in initClient us iniState "" ""
        forkIO $ process us state
        processConsole us
