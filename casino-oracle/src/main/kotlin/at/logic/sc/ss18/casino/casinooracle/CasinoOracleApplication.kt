package at.logic.sc.ss18.casino.casinooracle

import org.springframework.boot.CommandLineRunner
import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.context.properties.ConfigurationProperties
import org.springframework.boot.runApplication
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import org.web3j.protocol.Web3j
import org.web3j.protocol.http.HttpService

fun main(args: Array<String>) {
    runApplication<CasinoOracleApplication>(*args)
}

@SpringBootApplication
class CasinoOracleApplication(val web3j: Web3j) : CommandLineRunner {
    override fun run(vararg args: String?) {
        println(web3j.web3ClientVersion().send())
    }
}

@Configuration
@ConfigurationProperties(prefix = "casino")
class CasinoConfigurationProperties {

    lateinit var address : String

}

@Configuration
class Web3jConfiguration {

    @Bean(destroyMethod = "shutdown")
    fun web3j(config : Web3jConfigurationProperties) = Web3j.build(HttpService(config.networkAddress))
}

@Configuration
@ConfigurationProperties(prefix = "web3j")
class Web3jConfigurationProperties {

    var networkAddress = "http://localhost:8545/"

}

