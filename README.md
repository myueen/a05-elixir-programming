# a05-elixir-programming

team("edlyn jeyaraj, yueen ma, thomas kung")

edlyn jeyaraj: 730569503 yueen ma: 730572152 thomas kung: 730620459

Description: 

In this Sleeping Barber assignment, we implement three separate processes: customers, a waiting room, and a receptionist. We use a queue data structure to manage customers waiting for haircuts.

The process works as follows:

1. New customers are spawned at random time intervals.

2. The receptionist process handles each new customer by directing them to the waiting room.

3. The waiting room process manages the queue of waiting customers:

   - If the queue contains fewer than 6 customers, the waiting room:
     a) Adds the new customer to the queue
     b) Notifies the barber that a customer is waiting
     c) Tells the customer to wait in the queue

   - If the queue is full (6 customers), the waiting room:
     a) Informs the customer there is no space
     b) Sends the customer away

4. The barber process handles haircuts:

   - When customers are waiting, the barber:
     a) Requests the waiting room to remove the first customer from the queue
     b) Cuts the customer's hair (taking a random amount of time)
     c) Tells the customer their haircut is complete and they can leave
     d) Checks with the waiting room if more customers are waiting

   - If the queue is empty, the waiting room informs the barber, and the barber goes to sleep.

   - If the queue is not empty, the barber continues serving the next customer.
