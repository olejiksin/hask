import React from 'react';
import ReactDOM from 'react-dom';
import './index.css';
import App from './App';
import {BrowserRouter as Router, Route, Switch} from 'react-router-dom';

const Ap = () => (
    <Switch>
        <Route path={'/game'} component={App}/>
    </Switch>
);

ReactDOM.render(
    <Router>
        <Ap/>
    </Router>,
    document.getElementById('root')
);

