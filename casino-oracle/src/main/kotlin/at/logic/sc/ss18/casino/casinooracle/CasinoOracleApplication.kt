package at.logic.sc.ss18.casino.casinooracle

import org.springframework.boot.CommandLineRunner
import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.context.properties.ConfigurationProperties
import org.springframework.boot.runApplication
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import org.web3j.protocol.Web3j
import org.web3j.protocol.http.HttpService
import org.web3j.tx.ClientTransactionManager
import org.web3j.tx.TransactionManager
import org.web3j.tx.gas.ContractGasProvider
import org.web3j.tx.gas.DefaultGasProvider
import java.math.BigInteger
import java.time.ZonedDateTime

fun main(args: Array<String>) {
    runApplication<CasinoOracleApplication>(*args)
}

@SpringBootApplication
class CasinoOracleApplication(
        val web3j: Web3j,
        val casino: Casino
) : CommandLineRunner {
    override fun run(vararg args: String?) {
        println(web3j.web3ClientVersion().send())
        println(casino.setInformation(ZonedDateTime.now().toEpochSecond().BI, 100.BI).send())
    }
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

private val Int.BI: BigInteger
    get() = BigInteger.valueOf(this.toLong())
