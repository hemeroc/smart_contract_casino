package at.logic.sc.ss18.casino.casinooracle

import org.slf4j.Logger

import org.slf4j.LoggerFactory
import org.springframework.beans.factory.InjectionPoint
import org.springframework.beans.factory.config.BeanDefinition
import org.springframework.boot.context.properties.ConfigurationProperties
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import org.springframework.context.annotation.Scope
import org.web3j.protocol.Web3j
import org.web3j.protocol.http.HttpService
import org.web3j.tx.ClientTransactionManager
import org.web3j.tx.TransactionManager
import org.web3j.tx.gas.ContractGasProvider
import org.web3j.tx.gas.DefaultGasProvider

@Configuration
class LoggerConfiguration {

    @Bean
    @Scope(BeanDefinition.SCOPE_PROTOTYPE)
    fun logger(injectionPoint: InjectionPoint): Logger =
            LoggerFactory.getLogger(injectionPoint.methodParameter?.containingClass ?: this::class.java)

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
@ConfigurationProperties(prefix = "casino")
class CasinoConfigurationProperties {

    lateinit var address: String

}

@Configuration
@ConfigurationProperties(prefix = "web3j")
class Web3jConfigurationProperties {

    var networkAddress = "http://localhost:8545/"
    var accountAddress = ""

}
