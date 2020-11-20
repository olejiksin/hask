{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE OverloadedStrings #-}


module Api
  ( module Api
  , BaseUrl (..)
  , Scheme (..)
  , ClientM
  ) where

import Prelude hiding (lookup)

import Types
import Game


import GHC.IO.Encoding
import Control.Monad.Error.Class
import Control.Concurrent.STM.Map (Map, insert, lookup)
import Data.UUID (UUID)
import Data.UUID.V4 (nextRandom)
import Control.Concurrent.STM
import Control.Monad.IO.Class
import Control.Monad.Reader
import Network.HTTP.Client (newManager, defaultManagerSettings)
import Servant
import Servant.API
import Servant.Client

type AllGames = Map UUID GameState

type GameAPI = 
  "newGame" :> Post '[JSON] UUID
  :<|> "state" :> Header "gameId" UUID :> Get '[JSON] GameState
  :<|> "paint" :> Header "gameId" UUID :> ReqBody '[JSON] Line :> Post '[JSON] GameState

gameHandler :: AllGames -> AppM a -> Handler a
gameHandler = flip runReaderT

type AppM = ReaderT AllGames Handler

gameApi :: Proxy GameAPI
gameApi = Proxy

servGame:: AllGames -> Application
servGame allGames =
 serve gameApi
 $ hoistServer gameApi (gameHandler allGames) gameServer

gameServer :: ServerT GameAPI AppM
gameServer = 
 createNewPost :<|>
 stateGet :<|> 
 paintPost 
 where
  createNewPost::AppM UUID
  createNewPost = do
   allGames <- ask
   newGameId <- liftIO nextRandom
   liftIO $ atomically $ insert newGameId initialState allGames
   logFromServerAction $ "game with uuid was created: " ++ show newGameId
   return newGameId
   
  stateGet :: Maybe UUID ->AppM GameState
  stateGet Nothing = return400error $ "No uuid"
  stateGet (Just uuid) = do
   allGames <- ask
   gameState <- liftIO $ atomically $ lookup uuid allGames
   case gameState of
    Just gameState -> return gameState
    Nothing -> return400error $ "No game with uuid"
   
  paintPost:: Maybe UUID -> Line -> AppM GameState
  paintPost Nothing _ = return400error $ "No uuid, sry"
  paintPost maybeUuid@(Just uuid) line = do
   gameState <- stateGet maybeUuid
   case paintLine gameState line of
    Left errorMessage -> do
     return400error $ errorMessage
    Right modifiedGame -> do
     allGames <- ask
     liftIO $ atomically $ insert uuid modifiedGame allGames
     return modifiedGame
   
 
  return400error msg = throwError $ err400{errReasonPhrase = msg}
  
  logFromServerAction :: String -> AppM ()
  logFromServerAction message = liftIO $ print $ message
 



