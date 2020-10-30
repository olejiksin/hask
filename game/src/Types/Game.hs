{-# LANGUAGE DeriveGeneric #-}

module Types.Game where

import Types.Line
import Data.Aeson
import GHC.Generics

--Игрок: массив закрашенных им линий, его id(1 или 2), какой его цвет(зеленый/синий)
data Player=Player
{id::Int,
coloredLines::[Line],
color::Color
}deriving(Eq, Show, Read)
instance FromJSON Player
instance ToJSON Player

--Состояние игры: список из двух игроков, номер хода, cписок линий, получен ли треугольник, какой id победителя(0-default)
data StateGame=StateGame
{
players::[Player],
move::Int,
triangle::Bool,
lines::[Line],
result::Int
}deriving(Eq,Show,Read)
instance FromJSON StateGame
instance ToJSON StateGame