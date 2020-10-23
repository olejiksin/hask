{-# LANGUAGE DeriveGeneric #-}

module Types.Game where

import Types.Rules
import Types.Line
import Data.Aeson
import GHC.Generics


data Player=Player
{Id::Int,
coloredLines::[Line],
gotTriangle::Bool,
color::Color
}deriving(Eq, Show, Read)
instance FromJSON Player
instance ToJSON Player

type Draw = Line

data StateGame=StateGame
{
players::[Player],
rule::Rule,
move::Int,
whoseMove::Int,
triangle::Bool,
lines::[Line]
}deriving(Eq,Show,Read)
instance FromJSON StateGame
instance ToJSON StateGame