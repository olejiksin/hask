import './App.css';
import React from "react";
import axios from 'axios';
import * as Viva from "vivagraphjs";

const {useReducer, useEffect} = React;


function reducer(state, action) {
    switch (action.type) {
        case 'pl': {
            return {
                ...state, player: action.payload.color, id: action.payload.id
            }
        }
        case 'uuid': {
            return {
                ...state, uuid: action.payload
            }
        }
        case 'move': {
            return {
                ...state, move: action.payload
            }
        }
        case 'lose': {
            return {...state, game: action.payload}
        }
        case 'bot': {
            return {...state, bot: action.payload}
        }
    }
}

let flag1 = false;
let flag = false;

function App() {
    const initState = {
        id: null,
        player: null,
        uuid: null,
        game: null,
        move: 0,
        bot: null
    };
    const [state, dispatch] = useReducer(reducer, initState);

    function createNew() {
        axios.post('/newGame')
            .then((resp) => {
                dispatch({type: 'uuid', payload: resp.data});
            })
            .catch((er) => console.log(er));
    }

    const changer = (type, data) => {
        dispatch({type: type, payload: data});
    };

    let lines = document.getElementsByTagName('line');
    if (state.id !== null) {
        for (let i = 0; i < 15; i++) {
            lines[i].onclick = (event) => {
                console.log(event.target.id);
                if (state.move === state.id) {
                    paint(lines[i], event, lines[i].getAttribute('stroke'))
                }
            };
            if (state.id !== null && flag === false) {
                lines[i].setAttribute('id', lines[i].link.fromId + '' + lines[i].link.toId);
                lines[i].setAttribute('stroke', 'Black');
                if (i === 14) flag = true;
            }
        }
    }

    setTimeout(() => {
        clearInterval(d);
    }, 1000);


    let d = setInterval(() => {
        if (state.move !== state.id) {
            if (state.uuid !== null && state.player !== null) {
                axios.get('/state', {headers: {'gameId': state.uuid}})
                    .then((resp) => {
                        console.log(resp.data);
                        let lines = document.getElementsByTagName('line');
                        if (state.id !== null) {
                            for (let i = 14; i >= 0; i--) {
                                lines[i].setAttribute('stroke', resp.data.gameLines[14 - i].colorForLine);
                            }
                        }
                        if (resp.data.result !== 2) {
                            changer('lose', resp.data.result);
                        }
                        changer('move', resp.data.move);

                    })
                    .catch((er) => console.log(er));
            }
        }
    }, 900);

    const botSet = () => {
        if (state.id !== null) {
            let id = state.id === 0 ? 1 : 0;
            changer('bot', id);
        }
    };

    if (flag1 === false && state.bot === 0 && state.move===0) {
        setTimeout(() => {
            axios.post('/bot', null, {headers: {'gameId': state.uuid, 'bot': state.bot}})
                .then((resp)=>changer('move',resp.data.move))
                .catch((er) => console.log(er));
        }, 500);
    }

    const paint = (line, event, color) => {
        if (state.move === state.id && color === 'Black') {
            event.target.setAttribute('stroke', state.player);
            let data = {
                connection: [parseInt(line.getAttribute('id')[0]), parseInt(line.getAttribute('id')[1])],
                colorForLine: color
            };
            axios.post('/paint', data, {headers: {'gameId': state.uuid}})
                .then((resp) => {
                    console.log(resp.data);
                    changer('move', resp.data.move);
                })
                .catch((er) => console.log(er));
            setTimeout(() => {
                if (state.bot === 1 && state.result !== null && flag1===false) {
                    axios.post('/bot', null, {headers: {'gameId': state.uuid, 'bot': state.bot}})
                        .then(()=>changer('move',0))
                        .catch((er) => console.log(er));
                }
            }, 500);
        } else {
            console.log('ne tot')
        }
    };


    if (state.game !== 2 && state.game !== null && flag1 === false) {
        flag1 = true;
        alert(`Проиграл игрок: ${state.game === 0 ? 'Зеленый' : 'Красный'}`);
    }

    useEffect(() => {
        let graph = Viva.Graph.graph();
        for (let i = 1; i < 7; i++) {
            for (let j = i; j < 7; j++) {
                if (i !== j) {
                    graph.addLink(i, j);
                }
            }
        }
        let layout = Viva.Graph.Layout.forceDirected(graph, {
            springLength: 300,
            springCoeff: 0.0005,
            dragCoeff: 0.02,
            gravity: -1.2
        });

        let renderer = Viva.Graph.View.renderer(graph, {
            container: document.getElementById('game'),
            layout: layout
        });
        renderer.run();
    }, []);

    return (
        <div>
            <br/>
            <div className="App">
                <button onClick={() => createNew()}>Создать новую игру</button>
                <br/>
                <label>Или введите uuid другой игры:</label>
                <br/>
                <input onChange={(event) => changer('uuid', event.target.value)}/>
                <br/>
                <h4>UUID игры : {state.uuid}</h4>
                <h4>Граф можно приблизить, отдалить, двигать</h4>
                <h4>Выбрать цвет:</h4>
                <button onClick={() => {
                    let data = {
                        color: 'red',
                        id: 1
                    };
                    dispatch({type: 'pl', payload: data})
                }}>Красный
                </button>
                <button onClick={() => {
                    let data = {
                        color: 'green',
                        id: 0
                    };
                    dispatch({type: 'pl', payload: data})
                }}>Зеленый
                </button>
                <h3>Твой цвет : {state.player === null ? 'Nothing' : state.player}</h3>
                <h3>Играть с ботом?</h3>
                <button onClick={() => botSet()}>Да</button>
                <button>Нет</button>
                <br/>
                <h2>Сейчас ходит игрок
                    : {state.move === 1 ? 'Red player' : null || state.move === 0 ? 'Green player' : null}</h2>
                <div id={'game'}></div>
            </div>
        </div>
    );
}

export default App;
