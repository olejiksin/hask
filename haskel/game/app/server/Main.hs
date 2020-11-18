{-# LANGUAGE DataKinds #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE StandaloneDeriving #-}
{-# LANGUAGE TypeOperators #-}

module Main where

import Lib

import GHC.Generics
import GHC.IO.Encoding
import Network.Wai.Handler.Warp
import Options.Generic

data CliOpts w = CliOpts
  { port :: w ::: Int <?> "Port to run server"
  , host :: w ::: Maybe String <?> "Host preference"
  , timeout :: w ::: Maybe Int <?> "Timeout for Slowloris"
  } deriving (Generic)

instance ParseRecord (CliOpts Wrapped)
deriving instance Show (CliOpts Unwrapped)

main :: IO ()
main = do
  setLocaleEncoding utf8
  opts <- unwrapRecord "Eleusis server"
  app <- mkApp
  let settings = setPort (port opts) $
        maybe id (setHost . read) (host opts) $
        maybe id setTimeout (timeout opts) $
        defaultSettings
  runSettings settings app