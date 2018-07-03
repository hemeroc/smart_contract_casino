import React, {Component} from 'react';
import TextField from '@material-ui/core/TextField';
import * as web3 from "web3";
import Typography from "@material-ui/core/es/Typography/Typography";
import Card from "@material-ui/core/es/Card/Card";
import CardContent from "@material-ui/core/es/CardContent/CardContent";


export default class EnvironmentCard extends Component {

    CASINO_STORAGE_KEY = "casino-token";

    constructor(props) {
        super(props);

        this.state = {
            casinoAddress: localStorage.getItem(this.CASINO_STORAGE_KEY) || '',
            validCasinoAddress: localStorage.getItem(this.CASINO_STORAGE_KEY) !== null,
        };

        this.handleCasinoAddressChange = this.handleCasinoAddressChange.bind(this);
    }

    componentDidMount() {
        if (this.state.casinoAddress !== '' && typeof this.props.casinoChangeCallback === 'function') {
            this.props.casinoChangeCallback(this.state.casinoAddress);
        }
    }

    render() {
        return (
            <Card>
                <CardContent>
                    <Typography variant="headline" component="h3">
                        Environment Settings
                    </Typography>
                    <Typography component="p">
                        Please adapt the following settings according to truffle's migration output.
                    </Typography>

                    <TextField id="casinoAddress"
                               label="Casino Address"
                               required
                               value={this.state.casinoAddress}
                               error={!this.state.validCasinoAddress}
                               onChange={this.handleCasinoAddressChange}
                    />
                </CardContent>
            </Card>
        );
    }

    handleCasinoAddressChange(event) {
        const casinoAddress = event.target.value;
        const validCasinoAddress = web3.utils.isAddress(casinoAddress);

        this.setState({casinoAddress, validCasinoAddress});

        localStorage.setItem(this.CASINO_STORAGE_KEY, casinoAddress);
        if (typeof this.props.casinoChangeCallback === 'function') this.props.casinoChangeCallback(casinoAddress);
    }
}
