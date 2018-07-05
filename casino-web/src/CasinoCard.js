import React, {Component} from 'react';
import Typography from "@material-ui/core/Typography/Typography";
import Card from "@material-ui/core/Card/Card";
import CardContent from "@material-ui/core/CardContent/CardContent";
import Divider from "@material-ui/core/Divider/Divider";
import TextField from "@material-ui/core/TextField/TextField";
import Switch from "@material-ui/core/Switch/Switch";
import Button from "@material-ui/core/Button/Button";
import Web3 from 'web3';
import {sameAddress} from "./helpers";
import casinoDefinition from './abi/Casino.json';
import casinoTokenDefinition from './abi/CasinoToken.json';

export default class CasinoCard extends Component {

    constructor(props) {
        super(props);

        this.web3Provider = new Web3.providers.WebsocketProvider('ws://localhost:7545');
        this.web3 = new Web3(this.web3Provider);

        this.state = {
            bettingToken: 0,
            bettingLong: true,
        };

        this.handleBettingTokenChange = this.handleBettingTokenChange.bind(this);
        this.handleBettingLongChange = this.handleBettingLongChange.bind(this);
        this.handleBet = this.handleBet.bind(this);
        this.cashIn = this.cashIn.bind(this);
    }

    componentDidMount() {
        this.ensureUpToDateContracts();
    }

    componentDidUpdate(props, state, snapshot) {
        this.ensureUpToDateContracts();
    }

    async ensureUpToDateContracts() {
        if (this.props.casinoAddress === "") return;

        if (this.casinoContract === undefined || !sameAddress(this.casinoContract._address, this.props.casinoAddress)) {
            this.casinoContract = new this.web3.eth.Contract(casinoDefinition.abi, this.props.casinoAddress);
        }

        const tokenAddress = await this.casinoContract.methods.casinoTokenContractAddress().call();

        if (this.casinoTokenContract === undefined || !sameAddress(this.casinoTokenContract._address, tokenAddress)) {
            this.casinoTokenContract = new this.web3.eth.Contract(casinoTokenDefinition.abi, tokenAddress);
            this.casinoTokenContract.methods.balanceOf(this.props.address).call()
                .then((tokenBalance) => this.setState({tokenBalance}));
        }
    }

    render() {
        if (this.props.casinoAddress === "" || this.props.account === "") return (
            <Card>
                <CardContent>
                    <Typography variant="headline">
                        Casino Interaction
                    </Typography>
                    <Typography component="p" color="textSecondary">
                        Here you can gamble like a pro.
                    </Typography>

                    <Divider/>

                    <Typography>
                        Please configure a casino address and choose an account.
                    </Typography>
                </CardContent>
            </Card>
        );

        return (
            <Card>
                <CardContent>
                    <Typography variant="headline">
                        Casino Interaction
                    </Typography>
                    <Typography component="p" color="textSecondary">
                        Here you can gamble like a pro.
                    </Typography>

                    <Divider/>

                    <Typography variant="body2">
                        New Bet
                    </Typography>
                    <Typography>
                        <TextField id="bettingToken"
                                   label="Token"
                                   type="number"
                                   value={this.state.bettingToken}
                                   onChange={this.handleBettingTokenChange}
                        />
                    </Typography>
                    <Typography>
                        <Switch
                            checked={this.state.bettingLong}
                            onChange={this.handleBettingLongChange}
                            defaultChecked="true"
                        />
                        {this.state.bettingLong ? 'Long' : 'Short'}
                    </Typography>
                    <Button onClick={this.handleBet}>Send bet</Button>

                    <Divider/>

                    <Button onClick={this.cashIn}>Cash In</Button>
                </CardContent>
            </Card>
        );
    }

    handleBettingTokenChange(event) {
        this.setState({bettingToken: event.target.value});
    }

    handleBettingLongChange(event) {
        this.setState({bettingLong: event.target.checked});
    }

    async handleBet() {
        const transferResponse = await this.casinoTokenContract.methods.transfer(this.props.casinoAddress, this.state.bettingToken)
            .send({from: this.props.account});
        console.log("BetPlacement Transfer", transferResponse);

        const response = await this.casinoContract.methods.placeBet(this.state.bettingToken, this.state.bettingLong)
            .send({from: this.props.account, gas: 500000});
        console.log("BetPlacement result", response);
    }

    async cashIn() {
        const response = await this.casinoContract.methods.closeFinishedBets()
            .send({from: this.props.account, gas: 500000});
        console.log("BetPlacement result", response);
    }
}
