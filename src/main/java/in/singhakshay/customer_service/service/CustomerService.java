package in.singhakshay.customer_service.service;

import in.singhakshay.customer_service.model.Customer;

import java.util.List;

public interface CustomerService {
  List<Customer> listAllCustomers();
  Customer getCustomerById(String id);
}
