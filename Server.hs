module Main where

import Control.Monad.IO.Class
import Data.Functor
import IniConfig
import Network.MessagePack.Server
import System.Process
import Text.Read

import Common

cmd :: String -> Server ()
cmd = liftIO . void . callCommand

main :: IO ()
main = withXDGConfigFile "server.conf" $ \(Config defs ss) ->
    withJust (lookup "port" defs >>= readMaybe) (failConfig "invalid port") $ \port ->
        withJust (lookup "commands" ss) (failConfig "no commands specified") $
            serve port . map (\(n, c) -> method n $ cmd c)
