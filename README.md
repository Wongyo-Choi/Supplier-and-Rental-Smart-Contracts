# Supplier and Rental Smart Contracts

This repository contains two smart contracts written in Solidity – **Supplier** and **Rental**. These contracts interact with a payment lock (Paylock) mechanism and implement a basic rental system.

---

## Contract Descriptions

### Supplier Contract

The **Supplier** contract manages the supplier’s work status and interacts with an external **Paylock** contract.

- **Status Management:**  
  An enumeration (`enum`) called `State` is used to manage the supplier’s work status, which can either be `Working` or `Completed`.

- **Payment Signal:**  
  Once the work is complete, the `finish()` function is called. This function triggers the `signal()` method on the associated **Paylock** contract and updates the status to `Completed`.

- **Usage:**  
  1. Deploy the **Paylock** contract (which is not included in this repository).  
  2. Deploy the **Supplier** contract, providing the address of the deployed **Paylock** contract as an argument.  
  3. Call the `finish()` function once the work is completed to initiate the payment process.

---

### Rental Contract

The **Rental** contract implements a simple rental system.

- **Resource Availability:**  
  Upon deployment, the resource is initialised as available.

- **Renting Out the Resource:**  
  The `rent_out_resource()` function may be called when the resource is available. It sets the caller as the `resource_owner` and marks the resource as unavailable. (A payment verification mechanism can be incorporated here.)

- **Retrieving the Resource:**  
  The `retrieve_resource()` function is used to retrieve the resource. It verifies that the resource is currently rented and that the caller is the resource owner before marking the resource as available again. (A deposit return mechanism can be implemented here.)

- **Usage:**  
  1. Deploy the **Rental** contract.  
  2. When the resource is available, call the `rent_out_resource()` function to rent it.  
  3. The renter can subsequently call `retrieve_resource()` to return the resource.

---

## Prerequisites

- **Solidity Compiler:**  
  A Solidity compiler (version 0.4.22 or above) is required.

- **Ethereum Development Environment:**  
  You can compile and deploy these contracts using Ethereum development tools such as [Remix](https://remix.ethereum.org/) or [Truffle](https://www.trufflesuite.com/).

---

## Installation and Deployment

1. Clone the repository:
    ```bash
    git clone <repository-url>
    cd <repository-directory>
    ```

2. Open the Solidity files in your preferred development environment.

3. Compile the contracts.

4. Deploy the contracts to a local blockchain or testnet.

---

## Potential Improvements

- **Enhanced Payment Verification:**  
  Introduce a robust payment verification procedure within the `rent_out_resource()` function to ensure secure transactions.

- **Deposit Return Mechanism:**  
  Implement logic within `retrieve_resource()` to manage the return of deposits, thereby enhancing the trust and security of the rental process.

- **Access Control and Security:**  
  Strengthen access control measures for each function to prevent unauthorised usage and potential exploitation.

---

## Additional Notes

- **Paylock Contract:**  
  The **Supplier** contract relies on an external **Paylock** contract, which must be deployed separately. Ensure that the correct address of the **Paylock** contract is provided during the deployment of the **Supplier** contract.

- **Testing and Security Audit:**  
  As these contracts offer a basic framework, it is advisable to conduct thorough testing and a comprehensive security audit before deploying them on the main network.
