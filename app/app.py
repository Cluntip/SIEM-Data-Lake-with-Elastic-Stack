"""
Customer Service Application
A Flask REST API for customer management with ELK stack integration
"""
from flask import Flask, jsonify, request
from datetime import datetime
import logging
import json
import uuid

from models import Customer, get_all_customers, get_customer_by_id, create_sample_data
from log_config import setup_logging

app = Flask(__name__)

# Setup logging to Logstash
setup_logging(app)
logger = logging.getLogger(__name__)

# Initialize sample data
create_sample_data()


@app.route('/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    logger.info("Health check endpoint called")
    return jsonify({
        "status": "healthy",
        "timestamp": datetime.now().isoformat(),
        "service": "customer-service"
    })


@app.route('/api/v1/customers/all', methods=['GET'])
def get_all():
    """Get all customers"""
    logger.info("START - getAllCustomers")
    
    try:
        customers = get_all_customers()
        logger.info(f"Retrieved {len(customers)} customers")
        logger.info("END - getAllCustomers")
        
        return jsonify(customers), 200
    except Exception as e:
        logger.error(f"Error getting all customers: {str(e)}", exc_info=True)
        return jsonify({"error": "Internal server error"}), 500


@app.route('/api/v1/customers', methods=['GET'])
def get_customer():
    """Get customer by ID"""
    customer_id = request.args.get('customerId')
    
    if not customer_id:
        logger.warning("getCustomerById called without customerId parameter")
        return jsonify({"error": "customerId parameter is required"}), 400
    
    logger.info(f"START - getCustomerById, id: {customer_id}")
    
    try:
        customer = get_customer_by_id(customer_id)
        
        if customer is None:
            logger.error(f"Customer not found, id: {customer_id}")
            return jsonify({"error": "Customer not found"}), 404
        
        logger.info("END - getCustomerById")
        return jsonify(customer), 200
    except Exception as e:
        logger.error(f"Error getting customer by id {customer_id}: {str(e)}", exc_info=True)
        return jsonify({"error": "Internal server error"}), 500


@app.errorhandler(404)
def not_found(error):
    """Handle 404 errors"""
    logger.warning(f"404 error: {request.url}")
    return jsonify({"error": "Resource not found"}), 404


@app.errorhandler(500)
def internal_error(error):
    """Handle 500 errors"""
    logger.error(f"500 error: {str(error)}")
    return jsonify({"error": "Internal server error"}), 500


if __name__ == '__main__':
    logger.info("Starting Customer Service Application")
    app.run(host='0.0.0.0', port=8081, debug=False)
