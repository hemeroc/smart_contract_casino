package at.logic.sc.ss18.casino.casinooracle

import com.fasterxml.jackson.annotation.JsonProperty
import org.springframework.boot.CommandLineRunner
import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.context.properties.ConfigurationProperties
import org.springframework.boot.runApplication
import org.springframework.cloud.openfeign.EnableFeignClients
import org.springframework.cloud.openfeign.FeignClient
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import org.springframework.scheduling.annotation.EnableScheduling
import org.springframework.scheduling.annotation.Scheduled
import org.springframework.stereotype.Service
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RequestParam
import org.web3j.protocol.Web3j
import org.web3j.protocol.core.methods.request.EthFilter
import org.web3j.protocol.http.HttpService
import org.web3j.tx.ClientTransactionManager
import org.web3j.tx.TransactionManager
import org.web3j.tx.gas.ContractGasProvider
import org.web3j.tx.gas.DefaultGasProvider
import java.math.BigInteger
import java.time.ZonedDateTime
import java.util.PriorityQueue

fun main(args: Array<String>) {
    runApplication<CasinoOracleApplication>(*args)
}

@SpringBootApplication
@EnableScheduling
@EnableFeignClients
class CasinoOracleApplication(
        val casino: Casino,
        val etherPriceService: EtherPriceService,
        val cryptoPriceService: CryptoPriceService
) : CommandLineRunner {
    override fun run(vararg args: String?) =
            casino.observeBetPlacedEvents(EthFilter()).forEach { betPlacedEvent ->
                with(betPlacedEvent) {
                    etherPriceService.reportPriceToOracle(betPlacedTimestamp.toLong())
                    etherPriceService.reportPriceToOracle(betTimestamp.toLong())
                }
            }
}

@Service
class EtherPriceService(
        val casino: Casino,
        val cryptoPriceService: CryptoPriceService
) {

    val futureTimestamps = PriorityQueue<Long>()

    fun reportPriceToOracle(timestamp: Long) {
        if (isInPast(timestamp)) {
            publishPrice(timestamp, resolvePrice(timestamp))
        } else {
            futureTimestamps.add(timestamp)
        }
    }

    private fun isInPast(timestamp: Long) = timestamp <= ZonedDateTime.now().toEpochSecond()

    @Scheduled(fixedRate = 30000)
    fun continuouslyResolvePrices() =
            futureTimestamps
                    .takeWhile { isInPast(it) }
                    .forEach { publishPrice(it, resolvePrice(it)) }

    private fun publishPrice(timestamp: Long, price: Long) {
        casino.setInformation(timestamp.BI, price.BI).send()
    }

    private fun resolvePrice(timestamp: Long): Long =
            cryptoPriceService.retrievePrice(
                    fromSym = "ETH",
                    toSym = "EUR",
                    limit = 1,
                    timestamp = timestamp
            ).priceItems.last().price.times(100).toLong()

}


@FeignClient(name = "cryptocompare", url = "https://min-api.cryptocompare.com")
interface CryptoPriceService {

    @GetMapping("/data/histominute")
    fun retrievePrice(
            @RequestParam("fsym") fromSym: String,
            @RequestParam("tsym") toSym: String,
            @RequestParam("toTs") timestamp: Long,
            @RequestParam("limit") limit: Long
    ): CryproPriceResponse

    data class CryproPriceResponse(@JsonProperty("Data") val priceItems: List<PriceItem>)
    data class PriceItem(@JsonProperty("time") val timestamp: Long, @JsonProperty("close") val price: Double)

}

@Configuration
@ConfigurationProperties(prefix = "casino")
class CasinoConfigurationProperties {

    lateinit var address: String

}

@Configuration
class Web3jConfiguration {

    @Bean(destroyMethod = "shutdown")
    fun web3j(config: Web3jConfigurationProperties) = Web3j.build(HttpService(config.networkAddress))

    @Bean
    fun gasProvider(): ContractGasProvider = DefaultGasProvider()

    @Bean
    fun transactionManager(web3j: Web3j, config: Web3jConfigurationProperties): TransactionManager =
            ClientTransactionManager(web3j, config.accountAddress)


}

@Configuration
@ConfigurationProperties(prefix = "web3j")
class Web3jConfigurationProperties {

    var networkAddress = "http://localhost:8545/"
    var accountAddress = ""

}

private val Long.BI: BigInteger
    get() = BigInteger.valueOf(this)
