package at.logic.sc.ss18.casino.casinooracle

import com.fasterxml.jackson.annotation.JsonProperty
import org.slf4j.Logger
import org.springframework.cloud.openfeign.FeignClient
import org.springframework.scheduling.annotation.Scheduled
import org.springframework.stereotype.Service
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RequestParam
import java.math.BigInteger
import java.time.Duration
import java.time.ZonedDateTime
import java.util.PriorityQueue

@Service
class EtherPriceService(
        val casinoContract: CasinoContract,
        val cryptoComparePriceService: CryptoComparePriceService,
        val logger: Logger
) {

    val alreadyProcessedTimestamps = HashSet<Long>()
    val futureTimestamps = PriorityQueue<Long>()

    fun reportPriceToOracle(timestamp: Long) {
        if (alreadyProcessedTimestamps.contains(timestamp)) {
            logger.info("Skip processing of timestamp $timestamp, already processed")
            return
        }
        alreadyProcessedTimestamps.add(timestamp)
        if (inPast(timestamp)) {
            resolveAndPublishPrice(timestamp)
        } else {
            logger.info("Postpone processing of timestamp $timestamp, it is in future")
            futureTimestamps.add(timestamp)
        }
    }

    private fun inPast(timestamp: Long) = timestamp <= ZonedDateTime.now().toEpochSecond()

    private fun olderThen(timestamp: Long, duration: Duration) =
            timestamp <= ZonedDateTime.now().minus(duration).toEpochSecond()

    private fun resolveAndPublishPrice(timestamp: Long) {
        if (olderThen(timestamp, Duration.ofDays(7))) {
            logger.info("Skip processing of timestamp $timestamp, it is older then 7 days")
            return
        }
        try {
            val price = cryptoComparePriceService.retrievePrice(
                    fromSym = "ETH",
                    toSym = "EUR",
                    limit = 1,
                    timestamp = timestamp
            ).priceItems.last().price.times(100).toLong()
            logger.info("Retrieved a price $price for timestamp $timestamp")
            val status = casinoContract.setInformation(timestamp.BI, price.BI).status
            if (status != SUCCESS)
                throw RuntimeException("publish of price $price for timestamp $timestamp failed with status code $status")
            logger.info("Published price $price for timestamp $timestamp with status $status")
        } catch (e: Exception) {
            logger.error("Processing error while retrieving/publishing price for timestamp $timestamp, requeue timestamp", e)
            futureTimestamps.add(timestamp)
        }
    }

    @Scheduled(initialDelay = 30000, fixedDelay = 30000)
    fun continuouslyResolvePrices() {
        logger.info("Processing all unprocessed past timestamps")
        futureTimestamps
                .takeWhile { inPast(it) }
                .forEach { resolveAndPublishPrice(it) }
    }

}

@FeignClient(name = "CryptoCompare", url = "https://min-api.cryptocompare.com")
interface CryptoComparePriceService {

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

private const val SUCCESS = "1"

private val Long.BI: BigInteger
    get() = BigInteger.valueOf(this)
