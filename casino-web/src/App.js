import React, {Component} from 'react';
import './App.css';
import Web3 from 'web3';
import Header from "./Header";
import ChartBlock from "./ChartBlock";
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
        // TODO rewrite

        const coinbase = await this.web3.eth.getCoinbase();
        const balance = await this.web3.eth.getBalance(coinbase);

        this.balanceSubscription = this.web3.eth.subscribe('newBlockHeaders', () => {
            const balance = this.web3.eth.getBalance(coinbase);
            this.setState({balance})
        });

        this.setState({loading: false, coinbase, balance})
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
                <ChartBlock/>
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
