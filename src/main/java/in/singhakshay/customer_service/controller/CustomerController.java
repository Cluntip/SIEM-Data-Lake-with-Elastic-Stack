package in.singhakshay.customer_service.controller;

import in.singhakshay.customer_service.model.Customer;
import in.singhakshay.customer_service.service.CustomerService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/customers")
@RequiredArgsConstructor
@Slf4j
public class CustomerController {
  private final CustomerService customerService;

  @GetMapping("/all")
  public ResponseEntity<List<Customer>> getAllCustomers() {
    log.info("START - getAllCustomers");
    var customers = customerService.listAllCustomers();
    log.info("END - getAllCustomers");

    return ResponseEntity.ok(customers);
  }

  @GetMapping
  public ResponseEntity<Customer> getCustomerById(@RequestParam("customerId") String id) {
    log.info("START - getCustomerById, id: {}", id);
    var customer = customerService.getCustomerById(id);
    log.info("END - getCustomerById");

    return ResponseEntity.ok(customer);
  }
}
