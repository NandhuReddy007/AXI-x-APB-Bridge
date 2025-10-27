# AXI-APB-BRIDGE
# INTRODUCTION  
This project implements a high-performance AXI-to-APB bridge enabling seamless communication between high-speed AXI masters and APB peripherals. Implemented buffering mechanisms to sustain AXI-level throughput while maintaining reliable APB transfers. Supported five independent channels operating concurrently, ensuring parallel data handling without bottlenecks. Verified the bridge for speed, reliability, and protocol compliance, delivering a robust interface for high-performance SoC integration.  

# FEATURES  
•	Supports AXI4 read and write channels, including address, data, strobe and handshake signals.  
•	Converts AXI incremental burst transactions into APB single transactions.  
•	Handles APB3 protocol signals like PADDR, PSEL, PENABLE, PWRITE, PREADY, PRDATA, PSTRB, PSLVERR.  
•	Fully synchronous design with CLOCK and RESET handling.  
•	**PROTOCOL MAPPING**   
<img width="388" height="157" alt="image" src="https://github.com/user-attachments/assets/c12fc182-6ca1-4bab-9dbf-0e2aad29ebe9" />   

•	**HANDSHAKING SIGNALS**  
The DUT dynamically asserts ready signals (such as AWREADY, WREADY, etc.) based on the availability in its internal buffers, ensuring proper flow control and preventing data overflow during AXI transactions. 
The DUT dynamically asserts PSEL, PWRITE, PENABLE based on the availability in its internal buffers, ensuring proper flow control and preventing data overflow during APB transactions.   
•	**MAINTAINING AXI SPEED DATA FLOW**  
The AXI-to-APB bridge incorporates internal buffering mechanisms that allow it to temporarily store transactions, enabling the bridge to operate at AXI speeds while safely interfacing with the slower APB protocol. These buffers ensure continuous data flow, prevent data loss, and maintain high throughput across the bridge.    

# BLOCK DIAGRAM  
<img width="600" height="1000" alt="axi_awaddr (3)" src="https://github.com/user-attachments/assets/ee5c23dd-5172-4ecf-b01d-e1aaa0080903" />  

# WORKING  
The AXI-APB bridge acts as a protocol converter between a high-performance AXI bus and a lower-speed APB bus. It receives AXI transactions as an AXI slave, interprets them, and translates these into equivalent APB transactions to communicate with APB peripherals.  
•	Read Operation: When the AXI master issues a read request, the bridge captures the AXI read address and control signals, initiates an APB read cycle, and sends back the APB read data as an AXI read response.  
•	Write Operation: For AXI write requests, the bridge receives the AXI write address and data, then executes a corresponding APB write cycle to write the data to the peripheral, then sends the AXI write response.  
•	Address Decoding: It decodes AXI addresses to select the correct APB slave device.  
•	Handshaking: Uses AXI handshake signals (valid/ready) and APB handshake signals (psel, penable, pready) to synchronize data transfers.  
•	Burst Handling: AXI burst transactions are broken down into multiple APB single transfer transactions.  
•	Error Handling: If the APB slave asserts an error (PSLVERR), corresponding error responses are sent back to AXI.    

# OPERATION FLOW  
<img width="600" height="1000" alt="image" src="https://github.com/user-attachments/assets/ed2d1c11-d294-4379-a0a5-24d9899f2357" />  



# ARCHITECTURE  
<img width="600" height="1000" alt="image" src="https://github.com/user-attachments/assets/e2acde98-0a7a-4364-84af-77259f985aa2" />  

# WAVEFORMS  
<img width="940" height="367" alt="image" src="https://github.com/user-attachments/assets/f9508e75-3e70-4d8e-9651-e7d47e56e7c2" />  
<img width="940" height="367" alt="image" src="https://github.com/user-attachments/assets/611d0178-37ed-4c00-aeed-c38b853124d9" />












