import logging
from config import Config

logger = logging.getLogger("smart_harvest")
logger.setLevel(Config.LOG_LEVEL)

if not logger.handlers:
    ch = logging.StreamHandler()
    ch.setLevel(Config.LOG_LEVEL)
    formatter = logging.Formatter(
        "[%(asctime)s] [%(levelname)s] %(name)s: %(message)s"
    )
    ch.setFormatter(formatter)
    logger.addHandler(ch)
