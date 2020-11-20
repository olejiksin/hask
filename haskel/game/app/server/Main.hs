{-# LANGUAGE DataKinds #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE StandaloneDeriving #-}
{-# LANGUAGE TypeOperators #-}

module Main where

import Lib

import Options
import ServOpt
import Control.Lens.Lens ((&))
import Data.Streaming.Network.Internal (HostPreference (Host))
import GHC.Generics
import GHC.IO.Encoding
import Control.Concurrent.STM (atomically)
import Control.Concurrent.STM.Map (empty)
import Network.Wai.Handler.Warp
import Options.Generic

cliOpts :: ServOpt -> Settings
cliOpts opts = defaultSettings
 & setHost(Host $ opts & host)
 & setPort(opts & port)
 & setTimeout(opts & timeout)

main :: IO ()
main = runCommand $ \opts _ -> do
  setLocaleEncoding utf8
  let warpSets = cliOpts opts 
  allGames <- atomically empty
  runSettings warpSets $ servGame allGames