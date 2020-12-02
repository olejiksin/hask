import './App.css';
import React from "react";
import axios from 'axios';

const {useReducer} = React;

function reducer(state, action) {
    switch (action.type) {
        case 'pl': {
            return {
                ...state, player: action.payload
            }
        }
        case 'uuid': {
            return {
                ...state, gameUUID: action.payload
            }
        }
        case 'game': {
            return {
                ...state, data: action.payload
            }
        }
        case 'move': {
            return {
                ...state, move: action.payload
            }
        }
        case 'bot': {
            return {...state, bot: action.payload}
        }
        case 'seg': {
            return {...state, segment: action.payload}
        }
    }
}


function App() {
    const initState = {
        player: null,
        gameUUID: null,
        data: null,
        move: 'X',
        bot: null,
        segment: 'any'
    };
    const [state, dispatch] = useReducer(reducer, initState);

    const setBot = (checker) => {
        if (state.player !== null && checker === 'bot') {
            dispatch({type: 'bot', payload: state.player === 'X' ? 'O' : 'X'});
        }
        if (checker === 'null' && state.bot !== null) {
            dispatch({type: 'bot', payload: null});
        }
    };

    if (state.bot === state.move) {
        setTimeout(() => {
            let data = {
                GlobalBoardPosition: 0,
                LocalBoardPosition: 0,
                Player: state.bot
            };
            axios.post('/BotMove', data, {headers: {'Game-Uuid': state.gameUUID}})
                .then((resp) => {
                    change('move', state.bot === 'X' ? 'O' : 'X');
                })
                .catch((er) => console.log(er));
        }, 800);
    }


    let inter = setInterval(() => {
        if (state.gameUUID !== null && state.player !== null) {
            axios.get('/GetGameState', {headers: {'Game-Uuid': state.gameUUID}})
                .then((resp) => {
                    let boar = resp.data.GameBoard.CellList;
                    for (let i = 0; i < 9; i++) {
                        if (boar[i].SegmentState.State !== 'Free') {
                            console.log(resp.data.GameBoard);
                            document.getElementsByClassName('smallBoard ' + cellls[i])[0].innerHTML = null;
                            document.getElementsByClassName('smallBoard ' + cellls[i])[0].innerHTML = `${boar[i].SegmentState.OwnedBy}`;
                        }
                        for (let j = 0; j < 9; j++) {
                            if (boar[i].SegmentState.State === 'Free') {
                                let id = i + "" + j;
                                setTimeout(() => {
                                    if (boar[i].CellList[j].State !== 'Free') {
                                        document.getElementById(id).innerText = boar[i].CellList[j].OwnedBy;
                                        if (state.segment !== resp.data.LastPlayerTurn.LocalBoardPosition+1) {
                                            change('seg', resp.data.LastPlayerTurn.LocalBoardPosition+1);
                                        }
                                    }
                                }, 300);
                            }
                        }
                    }
                })
                .catch((er) => console.log(er))
        }
    }, 700);

    setTimeout(() => {
        clearInterval(inter)
    }, 800);

    function pushh(event) {
        if ((event.target.innerText !== 'X' || event.target.innerText !== 'O') && (state.player === 'X' || state.player === 'O')) {
            event.target.innerText = state.player;
            let data = {
                GlobalBoardPosition: parseInt(event.target.id[0]),
                LocalBoardPosition: parseInt(event.target.id[1]),
                Player: state.player
            };
            if (data.Player !== 'null') {
                dispatch({type: 'move', payload: state.move === 'X' ? 'O' : 'X'});
                change('seg', parseInt(event.target.id[0]) + 1);
                axios.post('/ApplyTurnToGameState', data, {headers: {'Game-Uuid': state.gameUUID}})
                    .then(() => {
                    })
                    .catch((er) => console.log(er));
            }
        }
    }

    function change(type, value) {
        if (type === 'pl') {
            dispatch({type: type, payload: value})
        } else {
            dispatch({type: type, payload: value})
        }
    }

    function createGame() {
        axios.post('/CreateNewGame')
            .then((resp) => {
                change('uuid', resp.data);
                change('bot', null);
                change('move', 'X');
                change('seg', 'any');
            })
            .catch((er) => console.log(er));
        let cells = document.getElementsByClassName('cell');
        for (const cell of cells) {
            cell.innerText = null;
        }
    }

    let cellls = ['NW', 'N', 'NE', 'W', 'C ', 'E', 'SW', 'S', 'SE'];
    let alCels = [];

    for (let j = 0; j < 9; j++) {
        for (let i = 0; i < 9; i++) {
            let b = alCels.push(<td onClick={(event) => pushh(event)} className={"cell " + cellls[i]}
                                    id={j + "" + i}/>);
        }
    }

    let al = [];
    for (let i = 0; i < 9; i++) {
        let b = al.push(<td className={"smallBoard " + cellls[i]}>
            <table>
                <tr>
                    {alCels[9 * i]}
                    {alCels[1 + 9 * i]}
                    {alCels[2 + 9 * i]}
                </tr>
                <tr>
                    {alCels[3 + 9 * i]}
                    {alCels[4 + 9 * i]}
                    {alCels[5 + 9 * i]}
                </tr>
                <tr>
                    {alCels[6 + 9 * i]}
                    {alCels[7 + 9 * i]}
                    {alCels[8 + 9 * i]}
                </tr>
            </table>
        </td>);
    }

    return (
        <div>
            <label>Input game uuid to connect </label>
            <br/>
            <input onChange={(event) => change('uuid', event.target.value)}/>
            <br/>
            <br/>
            <button onClick={() => createGame()}>OR create new game</button>
            <br/>
            <br/>
            <label>Game UUID</label>
            <br/>
            <label>{state.gameUUID}</label>
            <br/>
            <label>Input X or O</label>
            <br/>
            <input onChange={(event) => change('pl', event.target.value)}/>
            <br/>
            <label>Play with bot or not</label>
            <br/>
            <button onClick={() => setBot('bot')}>With bot</button>
            <button onClick={() => setBot('null')}>Nope</button>
            <h1>Whose move :{state.move}</h1>
            <h1>Segment for move :{state.segment}</h1>
            <div id="game" className="game ">
                <table>
                    <tr>
                        {al[0]}
                        {al[1]}
                        {al[2]}
                    </tr>
                    <tr>
                        {al[3]}
                        {al[4]}
                        {al[5]}
                    </tr>
                    <tr>
                        {al[6]}
                        {al[7]}
                        {al[8]}
                    </tr>
                </table>
            </div>
        </div>
    );
}


export default App;
