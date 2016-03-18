module Main where

import qualified Data.ByteString.Char8      as BS
import           IniConfig
import           Network.MessagePack.Client
import           System.Environment
import           Text.Read

import           Common

cmd :: String -> Client ()
cmd = call

main :: IO ()
main = withXDGConfigFile "client.conf" $ \(Config defs ss) ->
    withJust (lookup "ip" defs) (failConfig "missing ip") $ \ip ->
        withJust (lookup "port" defs >>= readMaybe) (failConfig "missing port") $ \port ->
            getArgs >>= execClient (BS.pack ip) port . mapM_ cmd
