{-# LANGUAGE DeriveGeneric #-}

module Player where

import Data.Aeson (ToJSON, FromJSON)
import GHC.Generics (Generic)
import Data.Swagger (ToSchema)

{-|
    Тип игрока.
    Используется для указания принадлежности ячейки одному из игроков,
    а также для идентификации игрока в составе хода.
-}
data Player = X | O deriving (Eq, Show, Generic)

instance ToJSON Player
instance FromJSON Player
instance ToSchema Player