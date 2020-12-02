module Main where

import Server (serverApplication)
import Logger (logMessage)

import Options
import Control.Lens.Lens ((&))

import Network.Wai.Handler.Warp
import ServerOptions
import Data.Streaming.Network.Internal (HostPreference (Host))

import Control.Concurrent.STM (atomically)
import Control.Concurrent.STM.Map (empty)

main :: IO ()
main = runCommand $ \options _ -> do
    logMessage $ "Running API on " ++ show options
    logMessage $ "SwaggerUI on " ++ fullAddress options ++ "/swagger-ui"
    let warpSettings = cliOptionsToWarpSettings options
    gameStorage <- atomically empty
    runSettings warpSettings $ serverApplication gameStorage

{-|
    Преобразовать параметры CLI в настройки warp.
-}
cliOptionsToWarpSettings :: ServerOptions -> Settings
cliOptionsToWarpSettings options
    = defaultSettings
        & setHost (Host $ options & host)
        & setPort (options & port)
        & setTimeout (options & timeout)