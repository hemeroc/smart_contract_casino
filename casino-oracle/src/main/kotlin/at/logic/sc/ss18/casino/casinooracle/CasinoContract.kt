package at.logic.sc.ss18.casino.casinooracle

import org.springframework.stereotype.Service
import org.web3j.abi.TypeReference
import org.web3j.abi.datatypes.Address
import org.web3j.abi.datatypes.Bool
import org.web3j.abi.datatypes.Event
import org.web3j.abi.datatypes.Function
import org.web3j.abi.datatypes.generated.Uint256
import org.web3j.protocol.Web3j
import org.web3j.protocol.core.methods.request.EthFilter
import org.web3j.tx.Contract
import org.web3j.tx.TransactionManager
import org.web3j.tx.gas.ContractGasProvider
import rx.Observable
import java.math.BigInteger
import java.util.Arrays

/**
 * Should be autogenerated but does not work dues to a bug in web3j in combination with a contract using openzeppelin
 */
@Service
class CasinoContract(casinoConfiguration: CasinoConfigurationProperties,
                     web3j: Web3j,
                     transactionManager: TransactionManager,
                     gasProvider: ContractGasProvider
) : Contract(NO_BINARY, casinoConfiguration.address, web3j, transactionManager, gasProvider) {

    fun observeBetPlacedEvents(filter: EthFilter): Observable<BetPlacedEvent> =
            web3j.ethLogObservable(filter)
                    .map { extractEventParametersWithLog(BET_PLACED_EVENT, it) }
                    .filter { it != null }
                    .map {
                        with(it) {
                            BetPlacedEvent(
                                    betTimestamp = nonIndexedValues[1].value as BigInteger,
                                    betPlacedTimestamp = nonIndexedValues[2].value as BigInteger
                            )
                        }
                    }

    fun setInformation(timestamp: BigInteger, price: BigInteger) = executeRemoteCallTransaction(
            Function("setInformation", listOf(Uint256(timestamp), Uint256(price)), emptyList())
    ).send()

    data class BetPlacedEvent(
            val betPlacedTimestamp: BigInteger,
            val betTimestamp: BigInteger
    )

}

private const val NO_BINARY = ""

private val BET_PLACED_EVENT = Event("BetPlaced", emptyList(),
        Arrays.asList<TypeReference<*>>(
                object : TypeReference<Address>() {},
                object : TypeReference<Uint256>() {},
                object : TypeReference<Uint256>() {},
                object : TypeReference<Bool>() {}
        ))
