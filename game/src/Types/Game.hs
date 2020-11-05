{-# LANGUAGE DeriveGeneric #-}

module Types.Game where

import Types.Line
import Data.Aeson(FromJSON,ToJSON)
import GHC.Generics

--Игрок: массив закрашенных им линий, его номер(1 или 2), какой его цвет(зеленый/синий)
data Player=Player
 {
 numb::Int,
 coloredLines::[Line],
 color::Color
 }deriving(Eq, Show, Read,Generic)
instance FromJSON Player
instance ToJSON Player

--Состояние игры: список из двух игроков, номер хода, cписок линий, получен ли треугольник, какой id победителя(0-default)
data GameState=GameState
 {
 players::[Player],
 move::Int,
 triangle::Bool,
 gameLines::[Line],
 result::Int
 }deriving(Eq,Show,Read,Generic)
instance FromJSON GameState
instance ToJSON GameState