module Types.Game where

import Types.Rules
import Types.Line

data Player=Player
{ colores::[Line],
gotTriangle::Bool
}deriving(Eq, Show, Read)

data Dot=Dot Int
	deriving(Eq,Show,Read,Ord)

type paint = Line

data StateGame=StateGame
{
players::[Player],
rule::Rule,
move::Int,

}deriving(Eq,Show,Read)