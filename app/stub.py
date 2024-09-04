import logging
import time

logger = logging.getLogger(__name__)


def run_stub(interval_seconds: int = 5):
    while True:
        logger.info(
            'Stub job pretends to do something for %s seconds...', interval_seconds
        )
        time.sleep(interval_seconds)
