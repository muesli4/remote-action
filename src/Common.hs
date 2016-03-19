module Common where

import Control.Monad.Loops (firstM)
import System.Directory
import System.Environment.XDG.BaseDir
import System.Exit

import IniConfig

progName :: String
progName = "remote-action"

withJust :: Maybe a -> b -> (a -> b) -> b
withJust m def f = maybe def f m

withEither :: Either a b -> (a -> c) -> (b -> c) -> c
withEither e l r = either l r e

withConfigFile :: FilePath -> (Config -> IO a) -> IO a
withConfigFile fp f = do
    exists <- doesFileExist fp
    if exists
    then do
        eConf <- readConfigFile fp
        withEither eConf failConfig f
    else failConfig "file not found"

-- | Tries to find a config file in the local path and then in the paths given
-- by the XDG standard.
withXDGConfigFile :: FilePath -> (Config -> IO a) -> IO a
withXDGConfigFile fn f = do
    xdgPaths <- getAllConfigFiles progName fn
    eConf <- do
        mFp <- firstM doesFileExist $ fn : xdgPaths
        withJust mFp (failConfig "no config file found") $ readConfigFile
    withEither eConf failConfig f

failConfig :: String -> IO a
failConfig msg = die $ "Failed to read configuration file: " ++ msg

