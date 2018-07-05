import React, {Component} from 'react';
import Typography from "@material-ui/core/Typography/Typography";
import Card from "@material-ui/core/Card/Card";
import Web3 from 'web3';
import TextField from "@material-ui/core/TextField/TextField";
import CardContent from "@material-ui/core/CardContent/CardContent";
import CardActions from "@material-ui/core/CardActions/CardActions";
import Button from "@material-ui/core/Button/Button";
import casinoTokenDefinition from './abi/CasinoToken.json';
import casinoDefinition from './abi/Casino.json';
import {sameAddress} from "./helpers";
import Divider from "@material-ui/core/Divider/Divider";

export default class TokenCard extends Component {

    constructor(props) {
        super(props);

        this.web3Provider = new Web3.providers.WebsocketProvider('ws://localhost:7545');
        this.web3 = new Web3(this.web3Provider);

        this.state = {
            tokenBalance: 0,
            tokenFormAmount: 0
        };

        this.handleTokenFormAmountChange = this.handleTokenFormAmountChange.bind(this);
        this.handleBuy = this.handleBuy.bind(this);
        this.handleSell = this.handleSell.bind(this);
    }

    componentDidMount() {
        this.ensureUpToDateContracts();
    }

    componentDidUpdate(props, state, snapshot) {
        if (props.account !== this.props.account) {
            this.transferSubscription.unsubscribe();
            this.transferSubscription = undefined;
        }

        this.ensureUpToDateContracts();
    }

    componentWillUnmount() {
        if (this.transferSubscription !== undefined) this.transferSubscription.unsubscribe();
    }

    render() {
        if (this.props.casinoAddress === "" || this.props.account === "") return (
            <Card>
                <CardContent>
                    <Typography variant="headline" component="h3">
                        Token Exchange
                    </Typography>
                    <Typography component="p">
                        Here you can exchange your hardly earned ether to casino tokens and back.
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
                    <Typography variant="headline" component="h3">
                        Token Exchange
                    </Typography>
                    <Typography component="p">
                        Here you can exchange your hardly earned ether to casino tokens and back.
                    </Typography>
                    <Typography component="p">
                        Balance: {this.state.tokenBalance} Tokens
                    </Typography>

                    <TextField id="tokenAmount"
                               label="Tokens"
                               type="number"
                               value={this.state.tokenFormAmount}
                               onChange={this.handleTokenFormAmountChange}
                    />
                </CardContent>

                <CardActions>
                    <Button onClick={this.handleBuy}>Buy</Button>
                    <Button onClick={this.handleSell}>Sell</Button>
                </CardActions>
            </Card>
        );
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

        if (this.transferSubscription === undefined) {
            this.casinoTokenContract.methods.balanceOf(this.props.account).call()
                .then((tokenBalance) => this.setState({tokenBalance}));

            this.transferSubscription = this.casinoTokenContract.events.Transfer().on("data", async (event) => {
                const from = event.returnValues.from;
                const to = event.returnValues.to;
                if (event.event === "Transfer" && (sameAddress(to, this.props.account) || sameAddress(from, this.props.account))) {
                    console.log("Token Balance Subscriber: Got Event ", event);
                    const tokenBalance = await this.casinoTokenContract.methods.balanceOf(this.props.account).call();
                    this.setState({tokenBalance});
                }
            });
        }
    }

    handleTokenFormAmountChange(event) {
        const tokenFormAmount = parseInt(event.target.value, 10);

        this.setState({tokenFormAmount});
    }

    async handleBuy() {
        if (this.state.tokenFormAmount < 0) return;

        const price = await this.casinoContract.methods.getCasinoTokenPrice().call();
        const value = price * this.state.tokenFormAmount;

        const response = await this.casinoContract.methods.buyCasinoToken().send({from: this.props.account, value});
        console.log("Buy result", response);
    }

    async handleSell() {
        if (this.state.tokenFormAmount < 0) return;

        const response = await this.casinoTokenContract.methods.transfer(this.props.casinoAddress, this.state.tokenFormAmount)
            .send({from: this.props.account});
        console.log("Sell result", response);
    }

}
