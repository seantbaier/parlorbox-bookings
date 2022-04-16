from loguru import logger

from function.data_sources import MerchantDataSource

BOOKINGS_EVENT = "BOOKINGS"


class BookingsService:
    def process_event(self, client, event: dict) -> dict:
        logger.info(f"BOOKING S3 PUT EVENT:::{BOOKINGS_EVENT}")
        merchants = MerchantDataSource(client)

        merchant = merchants.get_merchant(id=1)
        logger.info(merchant)

        return event


bookings = BookingsService()
