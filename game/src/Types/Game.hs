{-# LANGUAGE DeriveGeneric #-}

module Types.Game where

import Types.Line
import Data.Aeson
import GHC.Generics

--Игрок: массив закрашенных им линий, его id(1 или 2), какой его цвет(зеленый/синий), получил ли он треугольник  
data Player=Player
{id::Int,
coloredLines::[Line],
gotTriangle::Bool,
color::Color
}deriving(Eq, Show, Read)
instance FromJSON Player
instance ToJSON Player

type Draw = Line

--Состояние игры: массив из двух игроков, номер хода, кто делает ход, матрица линий, получен ли треугольник
data StateGame=StateGame
{
players::[Player],
move::Int,
whoseMove::Int,
triangle::Bool,
lines::[Line]
}deriving(Eq,Show,Read)
instance FromJSON StateGame
instance ToJSON StateGame