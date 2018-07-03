import React, {Component} from 'react';
import Typography from "@material-ui/core/es/Typography/Typography";
import Card from "@material-ui/core/es/Card/Card";
import Select from "@material-ui/core/es/Select/Select";
import MenuItem from "@material-ui/core/es/MenuItem/MenuItem";
import Web3 from 'web3';
import FormControl from "@material-ui/core/es/FormControl/FormControl";
import InputLabel from "@material-ui/core/es/InputLabel/InputLabel";
import CardContent from "@material-ui/core/es/CardContent/CardContent";

export default class Web3ClientCard extends Component {

    constructor(props) {
        super(props);

        this.web3Provider = new Web3.providers.HttpProvider('http://localhost:7545');
        this.web3 = new Web3(this.web3Provider);

        this.state = {
            account: '',
            accounts: [],
            balance: ''
        };

        this.handleAccountChange = this.handleAccountChange.bind(this);
    }

    componentDidMount = async () => {
        const accounts = await this.web3.eth.getAccounts();
        this.setState({accounts});
    };

    render() {
        const accountEntries = this.state.accounts
            .map((account) => <MenuItem value={account}>{account}</MenuItem>);

        return (
            <Card>
                <CardContent>

                    <Typography variant="headline" component="h3">
                        Ethereum Client Configuration
                    </Typography>

                    <FormControl>
                        <InputLabel htmlFor="account-id">Active Account</InputLabel>
                        <Select
                            value={this.state.account}
                            onChange={this.handleAccountChange}
                            inputProps={{
                                name: 'account',
                                id: 'account-id',
                            }}
                            style={{'min-width': "160px"}}
                        >
                            <MenuItem value=""> <em>None</em> </MenuItem>
                            {accountEntries}
                        </Select>
                    </FormControl>

                    <Typography component="p">
                        Balance: {this.web3.utils.fromWei(this.state.balance, 'ether')} Eth
                    </Typography>
                </CardContent>
            </Card>
        );
    }

    handleAccountChange(event) {
        const account = event.target.value;
        if (account === '') return;

        this.web3.eth.getBalance(account)
            .then((balance) => {
                this.props.accountChangeCallback(account);
                this.setState({account, balance});
            });
    }

}
