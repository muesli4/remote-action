module Main where

import Control.Monad.IO.Class
import Data.Functor
import IniConfig
import Network.MessagePack.Server
import Options.Applicative
import System.Process
import Text.Read

import Common

data CmdLineOpts = CmdLineOpts
                 { optPort       :: Maybe Int
                 , optConfigPath :: Maybe String
                 , cmds          :: (String, String)
                 } deriving Show



cmd :: String -> Server ()
cmd = liftIO . void . callCommand

main :: IO ()
main = execParser pi >>= print
--    withXDGConfigFile "server.conf" $ \(Config defs ss) ->
--        withJust (lookup "port" defs >>= readMaybe) (failConfig "invalid port") $ \port ->
--            withJust (lookup "commands" ss) (failConfig "no commands specified") $
--                serve port . map (\(n, c) -> method n $ cmd c)

  where
    optP = CmdLineOpts <$> optional (option auto (long "port" <> short 'p' <> metavar "PORT"))
                       <*> ((,) <$> strOption (short 'n' <> metavar "NAME") <*> strOption (short 'c' <> metavar "CMD"))
    cmdP = (,) <$> strOption (long "command" <> short 'c' <> metavar "NAME") <*> strArgument (metavar "CMD")
    pi   = info optP $ fullDesc --briefDesc "Provides a RPC service for predefined commands."
