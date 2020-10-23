{-# LANGUAGE DeriveGeneric #-}

module Types.Line where

import Types.Rules
import Types.Game
import Data.Aeson
import GHC.Generics


data Color
	= Green
	| Blue
	| Black
	deriving(Eq,Show,Read,Enum)
instance FromJSON Color
instance ToJSON Color
	
data Line=Line
{color::Color,
connection::[Int]
}deriving(Eq,Show,Read)
instance FromJSON Line
instance ToJSON Line

