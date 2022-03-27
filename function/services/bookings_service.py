from loguru import logger


from function.data_sources import MerchantProvider


BOOKINGS_EVENT = "BOOKINGS"


class BookingsService:
    def process_bookings_event(self, client, event: dict) -> dict:
        logger.info(f"BOOKING S3 PUT EVENT:::{BOOKINGS_EVENT}")
        merchants = MerchantProvider(client)

        merchant = merchants.get_merchant(id=1)
        logger.info(merchant)

        return event


bookings = BookingsService()
