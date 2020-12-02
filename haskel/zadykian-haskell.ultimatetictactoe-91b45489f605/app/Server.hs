{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE FlexibleContexts #-}

module Server (serverApplication) where

import Prelude hiding (lookup)

import Servant
import Servant.Swagger
import Data.Swagger
import Servant.Swagger.UI

import HttpApi
import Logger (logMessage)

import Data.UUID (UUID)
import Data.UUID.V4 (nextRandom)
import Control.Lens
import Control.Monad.Trans.Reader
import Control.Monad.IO.Class
import Control.Concurrent.STM.Map (Map, insert, lookup)

import Player
import GameState (GameState, newGameState, tryApplyTurn, getGlobalBoard)
import BoardSegment (state)
import PlayerTurn
import Control.Monad.Trans.Class (lift)
import Control.Concurrent.STM (atomically)
import BoardSegmentState

{-|
    Хранилище игровых партий.
-}
type GameStorage = Map UUID GameState

type AppM = ReaderT GameStorage Handler

gameStorageToHandler :: GameStorage -> AppM a -> Handler a
gameStorageToHandler = flip runReaderT

{-|
    Серверное приложение, инициализируемое хранилищем игровых партий.
-}
serverApplication :: GameStorage -> Application
serverApplication gameStorage =
    serve apiProxy
    $ hoistServer apiProxy (gameStorageToHandler gameStorage) httpServerWithSwagger

{-|
    Swagger-спецификация API.
-}
swaggerSpecification :: Swagger
swaggerSpecification = toSwagger (Proxy :: Proxy HttpApi)
    & info.title .~ "Ultimate Tic-Tac-Toe API"
    & info.version .~ "0.3.0.0"
    & info.description ?~ "API for communicating with game server."

{-|
    Поднять вычисление из Handler в AppM
-}
swaggerFromHandlerToAppM :: Server SwaggerApi -> ServerT SwaggerApi AppM
swaggerFromHandlerToAppM = hoistServer (Proxy :: Proxy SwaggerApi) lift

{-|
    Сервер Swagger-спецификации.
-}
swaggerDocServer :: ServerT SwaggerApi AppM
swaggerDocServer = swaggerFromHandlerToAppM $ swaggerSchemaUIServer swaggerSpecification

{-|
    HTTP-сервер игры.
-}
httpServerWithSwagger :: ServerT HttpApiWithSwagger AppM
httpServerWithSwagger =
    (createNewGame
    :<|> getGameState
    :<|> applyTurnToGame
    :<|> botMove)
    :<|> swaggerDocServer
    where
        {-|
            Создать новую игру на сервере.
        -}
        createNewGame :: AppM UUID
        createNewGame = do
            gameStorage <- ask
            newGameGuid <- liftIO nextRandom
            liftIO $ atomically $ insert newGameGuid newGameState gameStorage
            logFromServerAction $ "game with UUID '" ++ show newGameGuid ++ "' was created."
            return newGameGuid

        {-|
            Получить состояние игры по идентификатору.
        -}
        getGameState :: Maybe UUID -> AppM GameState
        getGameState Nothing = return400error "Game-Uuid header is required!"
        getGameState (Just gameUuid) = do
            gameStorage <- ask
            gameStateMaybe <- liftIO $ atomically $ lookup gameUuid gameStorage
            case gameStateMaybe of
                Just gameState -> return gameState
                Nothing -> return400error $ "Game with UUID '" ++ show gameUuid ++ "' does not exist!"

        {-|
            Применить ход к состоянию игры.
        -}
        applyTurnToGame :: Maybe UUID -> PlayerTurn -> AppM GameState
        applyTurnToGame Nothing _ = return400error "Game-Uuid header is required!"
        applyTurnToGame maybeGuid@(Just gameGuid) playerTurn = do
            gameState <- getGameState maybeGuid
            case tryApplyTurn playerTurn gameState of
                Left errorMessage -> do
                    logFromServerAction $ 
                        "attempt to make invalid turn '" ++ show playerTurn ++ 
                        "' in game with UUID '" ++ show gameGuid ++ "'." 
                    return400error errorMessage
                Right modifiedGameState -> do
                    gameStorage <- ask
                    liftIO $ atomically $ insert gameGuid modifiedGameState gameStorage
                    case state $ getGlobalBoard modifiedGameState of
                        Owned playerOfTurn -> logFromServerAction $ 
                            "game '" ++ show gameGuid ++ 
                            "' is won by player '" ++ show playerOfTurn ++ "'."
                        _ -> return ()
                    return modifiedGameState


        botMove :: Maybe UUID -> PlayerTurn -> AppM GameState
        botMove Nothing _ = return400error "No uuid"
        botMove maybeGuid@(Just gameGuid) playerTurn = do
         gameState <- getGameState maybeGuid
         let newMoveForBot = generateBotMove (player (playerTurn)) gameState
         case tryApplyTurn newMoveForBot gameState of
          Left errorMessage -> do 
           logFromServerAction $ "invalid turn" ++show newMoveForBot
           return400error errorMessage
          Right modifiedGameState -> do
           gameStorage <- ask
           liftIO $ atomically $ insert gameGuid modifiedGameState gameStorage
           case state $ getGlobalBoard modifiedGameState of
            Owned playerOfTurn -> logFromServerAction $
             "game '" ++ show gameGuid ++
             "' is won by player '" ++ show playerOfTurn
            _ -> return ()
           return modifiedGameState



        -- Сформировать ответ с кодом завершения '400 Bad Request'.
        return400error message = throwError $ err400 { errReasonPhrase = message }

        -- Записать в лог сообщение, находясь в монаде AppM.
        logFromServerAction :: String -> AppM ()
        logFromServerAction message = liftIO $ logMessage message