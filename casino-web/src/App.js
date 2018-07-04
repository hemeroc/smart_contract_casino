import React, {Component} from 'react';
import './App.css';
import Web3 from 'web3';
import Header from "./Header";
import Actions from "./Actions";
import EnvironmentCard from "./EnvironmentCard";
import Web3ClientCard from "./Web3ClientCard";
import TokenCard from "./TokenCard";
import CasinoCard from "./CasinoCard";

export default class App extends Component {

    constructor(props) {
        super(props);

        this.web3Provider = new Web3.providers.HttpProvider('http://localhost:7545');
        this.web3 = new Web3(this.web3Provider);

        this.state = {
            loading: true,
            account: '',
            casinoAddress: '',
        };

        this.accountChangeHandler = this.accountChangeHandler.bind(this);
        this.casinoChangeHandler = this.casinoChangeHandler.bind(this);
    }

    componentDidMount = async () => {
        this.setState({loading: false})
    };

    accountChangeHandler(account) {
        this.setState({account});
    }

    casinoChangeHandler(casinoAddress) {
        this.setState({casinoAddress});
    }

    render() {
        if (this.state.loading) return <div>Loading</div>;

        return (
            <div className="App">
                <Header/>
                {/*<ChartBlock/>*/}
                <Web3ClientCard accountChangeCallback={this.accountChangeHandler} account={this.state.account}/>
                <EnvironmentCard casinoChangeCallback={this.casinoChangeHandler}/>
                <TokenCard account={this.state.account}
                           casinoAddress={this.state.casinoAddress}
                />
                <CasinoCard account={this.state.account}
                            casinoAddress={this.state.casinoAddress}
                />
                <Actions/>
            </div>
        );
    }
}
