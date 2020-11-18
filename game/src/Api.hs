{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}

module Api
  ( module Api
  , BaseUrl (..)
  , Scheme (..)
  , ClientM
  ) where

import Types
import Game


import GHC.IO.Encoding

import Control.Concurrent.STM
import Control.Monad.IO.Class
import Control.Monad.Reader
import Network.HTTP.Client (newManager, defaultManagerSettings)
import Servant
import Servant.API
import Servant.Client

type GameAPI = "state" :> Get '[JSON] GameState
  :<|> "paint" :> ReqBody '[JSON] Line :> Post '[JSON] GameState

type AppM = ReaderT (TMVar GameState) Handler


gameServer :: ServerT GameAPI AppM
gameServer = stateGet :<|> paintPost

stateGet :: AppM GameState
stateGet = do
  sv <- ask
  s <- liftIO $ atomically $ readTMVar sv
  pure s

paintPost::Line ->AppM GameState
paintPost line = do
 sv <- ask
 gs' <- liftIO $ atomically $ do
  gs <- takeTMVar sv
  case paintLine gs line of
   Left e -> pure $ Left e
   Right gs' -> do
    putTMVar sv gs'
    pure $ Right gs'
 case gs' of
  Left _e -> throwError err401
  Right gs' -> pure gs'

gameApi :: Proxy GameAPI
gameApi = Proxy


mkApp :: IO Application
mkApp = do
 --setLocaleEncoding utf8
 s <- return initialState
 sv <- newTMVarIO s
 pure $ 
  serve gameApi $
  hoistServer gameApi (flip runReaderT sv) gameServer
 
getState :: ClientM GameState
postPaint :: Line -> ClientM GameState
getState :<|> postPaint = client gameApi 
 
runClient :: BaseUrl -> ClientM a -> IO (Either ClientError a)
runClient baseUrl actions = do
  mgr <- newManager defaultManagerSettings
  runClientM actions $ mkClientEnv mgr baseUrl
