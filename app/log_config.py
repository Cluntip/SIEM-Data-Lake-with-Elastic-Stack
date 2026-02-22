"""
Logging configuration for sending logs to Logstash
"""
import logging
import socket
import json
from datetime import datetime
from logging.handlers import SocketHandler


class LogstashFormatter(logging.Formatter):
    """Custom formatter for Logstash JSON format"""
    
    def format(self, record):
        log_data = {
            "@timestamp": datetime.utcnow().isoformat(),
            "message": record.getMessage(),
            "level": record.levelname,
            "logger_name": record.name,
            "thread": record.thread,
            "application": "customer-service",
            "environment": "development"
        }
        
        # Add exception info if present
        if record.exc_info:
            log_data["exception"] = self.formatException(record.exc_info)
        
        # Add extra fields
        if hasattr(record, 'customer_id'):
            log_data["customer_id"] = record.customer_id
        
        return json.dumps(log_data)


def setup_logging(app):
    """Setup logging configuration"""
    
    # Create console handler
    console_handler = logging.StreamHandler()
    console_handler.setLevel(logging.INFO)
    console_formatter = logging.Formatter(
        '%(asctime)s - %(levelname)s - %(name)s - %(message)s',
        datefmt='%Y-%m-%d %H:%M:%S'
    )
    console_handler.setFormatter(console_formatter)
    
    # Create Logstash handler
    try:
        logstash_handler = SocketHandler('logstash', 5044)
        logstash_handler.setLevel(logging.INFO)
        logstash_handler.setFormatter(LogstashFormatter())
        
        # Configure root logger
        root_logger = logging.getLogger()
        root_logger.setLevel(logging.INFO)
        root_logger.addHandler(console_handler)
        root_logger.addHandler(logstash_handler)
        
        app.logger.info("Logging configured successfully with Logstash integration")
    except Exception as e:
        # If Logstash is not available, just use console logging
        root_logger = logging.getLogger()
        root_logger.setLevel(logging.INFO)
        root_logger.addHandler(console_handler)
        
        app.logger.warning(f"Could not connect to Logstash: {e}. Using console logging only.")
