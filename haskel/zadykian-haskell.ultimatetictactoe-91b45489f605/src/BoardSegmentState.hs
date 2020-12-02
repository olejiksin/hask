{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE OverloadedStrings #-}

module BoardSegmentState (BoardSegmentState(..)) where

import Player (Player)

import Data.Aeson 
    (
        ToJSON, toJSON,
        object, (.=), 
        FromJSON
    )

import Data.Swagger 
    (
        ToSchema,
        declareNamedSchema,
        genericDeclareNamedSchemaUnrestricted,
        defaultSchemaOptions
    )
    
import GHC.Generics (Generic)

{-|
    Состояние сегмента игрового поля.
    Доступные значения: захвачена игроком 'X' или 'O'; свободна.
-}
data BoardSegmentState = Owned Player | Free deriving (Eq, Show, Generic)

instance ToJSON BoardSegmentState where
    toJSON (Owned player) = object 
        [
            "State" .= ("Owned" :: String),
            "OwnedBy" .= show player
        ]
    toJSON Free = object
        [
            "State" .= show Free
        ]

instance FromJSON BoardSegmentState

instance ToSchema BoardSegmentState where
    declareNamedSchema = genericDeclareNamedSchemaUnrestricted defaultSchemaOptions