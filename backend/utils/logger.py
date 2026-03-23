<<<<<<< HEAD
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
=======
# backend/utils/logger.py
import logging, sys

def get_logger(name: str) -> logging.Logger:
    logger = logging.getLogger(name)
    if not logger.handlers:
        handler = logging.StreamHandler(sys.stdout)
        handler.setFormatter(logging.Formatter(
            "[%(asctime)s] %(levelname)s %(name)s — %(message)s",
            datefmt="%Y-%m-%d %H:%M:%S",
        ))
        logger.addHandler(handler)
        logger.setLevel(logging.DEBUG)
    return logger
>>>>>>> ddbef5e9db3a8e5ea8f1ef25cdf5bcfa36295850
