{-# LANGUAGE DataKinds                  #-}
{-# LANGUAGE DeriveGeneric              #-}
{-# LANGUAGE OverloadedStrings          #-}

module PlayerTurn 
    (
        PlayerTurn(..),
        globalPosition,
        localPosition, 
        player
    ) where

import Player (Player(..))
import CellPosition (CellPosition)

import Control.Applicative (empty)
import GHC.Generics (Generic)
import Control.Lens ((&), (?~), mapped)

import Data.Aeson
    (
        ToJSON, toJSON,
        FromJSON, parseJSON,
        Value(..), object, (.=), (.:)
    )

import Data.Swagger
    (
        ToSchema, declareNamedSchema,
        genericDeclareNamedSchema, defaultSchemaOptions, 
        schema, description, example
    )

{-|
    Ход игрока.
-}
data PlayerTurn = PlayerTurn [CellPosition] Player deriving (Eq, Show, Generic)

instance ToJSON PlayerTurn where
    toJSON playerTurn = object
        [
            "GlobalBoardPosition" .= globalPosition playerTurn,
            "LocalBoardPosition" .= localPosition playerTurn,
            "Player" .= player playerTurn
        ]

instance FromJSON PlayerTurn where
    parseJSON (Object jsonValue) = do
        globalBoardPosition <- jsonValue .: "GlobalBoardPosition"
        localBoardPosition <- jsonValue .: "LocalBoardPosition"
        playerOfTurn <- jsonValue .: "Player"
        return $ PlayerTurn [globalBoardPosition, localBoardPosition] playerOfTurn
    parseJSON _ = empty

instance ToSchema PlayerTurn where
    declareNamedSchema proxy = genericDeclareNamedSchema defaultSchemaOptions proxy
        & mapped.schema.description ?~ "Player's turn example."
        & mapped.schema.example ?~ toJSON (PlayerTurn (map toEnum [4, 4]) X)

{-|
    Получить глобальную позицию в составе хода.
-}
globalPosition :: PlayerTurn -> CellPosition
globalPosition (PlayerTurn positionsList _) = head positionsList

{-|
    Получить локальную позицию в составе хода.
-}
localPosition :: PlayerTurn -> CellPosition
localPosition (PlayerTurn positionsList _) = positionsList !! 1

{-|
    Получить игрока, выполняющего ход.
-}
player :: PlayerTurn -> Player
player (PlayerTurn [] playerOfTurn) = playerOfTurn
player (PlayerTurn (_ : innerPart) playerOfTurn) = player $ PlayerTurn innerPart playerOfTurn