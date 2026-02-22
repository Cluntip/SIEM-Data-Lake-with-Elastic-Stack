"""
Customer model and data management
"""
import uuid
from datetime import datetime

# In-memory storage for customers (simulating database)
customers_db = {}


class Customer:
    """Customer model"""
    
    def __init__(self, name, email, phone, address, city, state, country, customer_id=None):
        self.id = customer_id or str(uuid.uuid4())
        self.name = name
        self.email = email
        self.phone = phone
        self.address = address
        self.city = city
        self.state = state
        self.country = country
        self.created_at = datetime.now().isoformat()
    
    def to_dict(self):
        """Convert customer to dictionary"""
        return {
            "id": self.id,
            "name": self.name,
            "email": self.email,
            "phone": self.phone,
            "address": self.address,
            "city": self.city,
            "state": self.state,
            "country": self.country,
            "created_at": self.created_at
        }


def get_all_customers():
    """Get all customers from in-memory storage"""
    return [customer.to_dict() for customer in customers_db.values()]


def get_customer_by_id(customer_id):
    """Get customer by ID"""
    customer = customers_db.get(customer_id)
    return customer.to_dict() if customer else None


def add_customer(customer):
    """Add customer to in-memory storage"""
    customers_db[customer.id] = customer


def create_sample_data():
    """Create sample customer data"""
    sample_customers = [
        Customer(
            name="John Doe",
            email="john.doe@example.com",
            phone="+1-555-0101",
            address="123 Main St",
            city="New York",
            state="NY",
            country="USA"
        ),
        Customer(
            name="Jane Smith",
            email="jane.smith@example.com",
            phone="+1-555-0102",
            address="456 Oak Ave",
            city="Los Angeles",
            state="CA",
            country="USA"
        ),
        Customer(
            name="Bob Johnson",
            email="bob.johnson@example.com",
            phone="+1-555-0103",
            address="789 Pine Rd",
            city="Chicago",
            state="IL",
            country="USA"
        ),
        Customer(
            name="Alice Williams",
            email="alice.williams@example.com",
            phone="+1-555-0104",
            address="321 Elm St",
            city="Houston",
            state="TX",
            country="USA"
        ),
        Customer(
            name="Charlie Brown",
            email="charlie.brown@example.com",
            phone="+1-555-0105",
            address="654 Maple Dr",
            city="Phoenix",
            state="AZ",
            country="USA"
        )
    ]
    
    for customer in sample_customers:
        add_customer(customer)
