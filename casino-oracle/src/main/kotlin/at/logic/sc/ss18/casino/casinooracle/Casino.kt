package at.logic.sc.ss18.casino.casinooracle

import org.web3j.abi.EventEncoder
import org.web3j.abi.TypeReference
import org.web3j.abi.datatypes.Event
import org.web3j.abi.datatypes.Function
import org.web3j.abi.datatypes.generated.Uint256
import org.web3j.protocol.Web3j
import org.web3j.protocol.core.DefaultBlockParameter
import org.web3j.protocol.core.RemoteCall
import org.web3j.protocol.core.methods.request.EthFilter
import org.web3j.protocol.core.methods.response.Log
import org.web3j.protocol.core.methods.response.TransactionReceipt
import org.web3j.tx.Contract
import org.web3j.tx.TransactionManager
import org.web3j.tx.gas.ContractGasProvider
import rx.Observable
import java.math.BigInteger
import java.util.*

/**
 * Should be autogenerated but does not work dues to a bug in web3j in combination with a contract useing openzeppelin
 * TODO: make contract more idiomatic
 */
class Casino(contractAddress: String,
             web3j: Web3j,
             transactionManager: TransactionManager,
             gasProvider: ContractGasProvider
) : Contract(BINARY, contractAddress, web3j, transactionManager, gasProvider) {

    fun getOracleInformationReceivedEvents(transactionReceipt: TransactionReceipt): List<OracleInformationReceivedEventResponse> =
            extractEventParametersWithLog(ORACLE_INFORMATION_RECEIVED_EVENT, transactionReceipt)
                    .map {
                        OracleInformationReceivedEventResponse(
                                log = it.log,
                                _utcTimestamp = it.nonIndexedValues[0].value as BigInteger,
                                _price = it.nonIndexedValues[1].value as BigInteger
                        )
                    }

    fun oracleInformationReceivedEventObservable(filter: EthFilter): Observable<OracleInformationReceivedEventResponse> =
            web3j.ethLogObservable(filter).map { log ->
                val eventValues = extractEventParametersWithLog(ORACLE_INFORMATION_RECEIVED_EVENT, log)
                OracleInformationReceivedEventResponse(
                        log = log,
                        _utcTimestamp = eventValues.nonIndexedValues[0].value as BigInteger,
                        _price = eventValues.nonIndexedValues[1].value as BigInteger
                )
            }

    fun oracleInformationReceivedEventObservable(startBlock: DefaultBlockParameter, endBlock: DefaultBlockParameter):
            Observable<OracleInformationReceivedEventResponse> {
        val filter = EthFilter(startBlock, endBlock, getContractAddress())
        filter.addSingleTopic(EventEncoder.encode(ORACLE_INFORMATION_RECEIVED_EVENT))
        return oracleInformationReceivedEventObservable(filter)
    }

    fun setInformation(_utcTimestamp: BigInteger, _price: BigInteger): RemoteCall<TransactionReceipt> =
            executeRemoteCallTransaction(
                    Function("setInformation", listOf(Uint256(_utcTimestamp), Uint256(_price)), emptyList())
            )

    data class OracleInformationReceivedEventResponse(
            val log: Log? = null,
            val _utcTimestamp: BigInteger? = null,
            val _price: BigInteger? = null
    )

    companion object {

        // TODO: remember to change after final contract is finished
        // why the hell is this even needed???
        private const val BINARY = "0x608060405234801561001057600080fd5b506040516020806102b9833981016040525" +
                "16000811161002f57600080fd5b600055610278806100416000396000f3006080604052600436106100775763ff" +
                "ffffff7c0100000000000000000000000000000000000000000000000000000000600035041663117de2fd81146" +
                "1007c57806336eca4d9146100af5780634c123019146100d6578063dd1ade5e14610166578063ebed73e9146101" +
                "6e578063fe4b8f1614610186575b600080fd5b34801561008857600080fd5b506100ad73fffffffffffffffffff" +
                "fffffffffffffffffffff600435166024356101a1565b005b3480156100bb57600080fd5b506100c46101e9565b" +
                "60408051918252519081900360200190f35b3480156100e257600080fd5b50604080516020601f6064356004818" +
                "101359283018490048402850184019095528184526101529473ffffffffffffffffffffffffffffffffffffffff" +
                "81358116956024803590921695604435953695608494019181908401838280828437509497506101ef965050505" +
                "0505050565b604080519115158252519081900360200190f35b6100ad6101f9565b34801561017a57600080fd5b" +
                "506100ad6004356101fb565b34801561019257600080fd5b506100ad60043560243561020d565b60405173fffff" +
                "fffffffffffffffffffffffffffffffffff83169082156108fc029083906000818181858888f193505050501580" +
                "156101e4573d6000803e3d6000fd5b505050565b60005490565b6000949350505050565b565b600081116102085" +
                "7600080fd5b600055565b604080518381526020810183905281517f364bb78414e01a80e9a9e528d8f3c18efc79" +
                "0d7c6cd14e63fab523f2e1623233929181900390910190a150505600a165627a7a72305820ae57d67099fba0979" +
                "f915e1e20d584a30c2318bf1d0d3226e139cb9aa1c995460029"

        val ORACLE_INFORMATION_RECEIVED_EVENT = Event("OracleInformationReceived", emptyList(),
                Arrays.asList<TypeReference<*>>(
                        object : TypeReference<Uint256>() {},
                        object : TypeReference<Uint256>() {}
                ))

    }

}