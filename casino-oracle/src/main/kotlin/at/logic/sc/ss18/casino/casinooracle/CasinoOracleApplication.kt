package at.logic.sc.ss18.casino.casinooracle

import org.slf4j.Logger
import org.springframework.boot.CommandLineRunner
import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.runApplication
import org.springframework.cloud.openfeign.EnableFeignClients
import org.springframework.scheduling.annotation.EnableScheduling
import org.web3j.protocol.core.methods.request.EthFilter

fun main(args: Array<String>) {
    runApplication<CasinoOracleApplication>(*args)
}

@SpringBootApplication
@EnableScheduling
@EnableFeignClients
class CasinoOracleApplication(
        val casino: CasinoContract,
        val etherPriceService: EtherPriceService,
        val logger: Logger
) : CommandLineRunner {
    override fun run(vararg args: String?) {
        logger.info("Oracle started successfully: waiting for events")
        casino.observeBetPlacedEvents(EthFilter()).forEach { betPlacedEvent ->
            logger.info("Processing event: $betPlacedEvent")
            with(betPlacedEvent) {
                etherPriceService.reportPriceToOracle(betPlacedTimestamp.toLong())
                etherPriceService.reportPriceToOracle(betTimestamp.toLong())
            }
        }
    }
}
