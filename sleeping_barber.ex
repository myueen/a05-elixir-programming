defmodule SleepingBarber do

    # for each customer
    def new do
        pid_wr =  spawn_link(__MODULE__, :waiting_room, [[]])
        pid_r =  spawn_link(__MODULE__, :receptionist, [pid_wr])
        pid_b =  spawn_link(__MODULE__, :barber, [pid_wr])

        spawn_link(__MODULE__, :loop, [pid_wr, pid_r, pid_b])
        {:ok, %{barber: pid_b, receptionist: pid_r, waiting_room: pid_wr}}
    end

    def loop(pid_wr, pid_r, pid_b) do
        pid_c =  spawn_link(__MODULE__, :customer, [pid_r])
        send(pid_r, {:receptionist, pid_b, pid_c})

        random_number = :rand.uniform(9)    # random number between 1 and 9
        :timer.sleep(1000*random_number)
        SleepingBarber.loop(pid_wr, pid_r, pid_b)

    end


    # receptionist
    def receptionist(waiting_room) do
        receive do
            {:receptionist, barber, pid_c} ->
                IO.puts("Greeting #{inspect(pid_c)}")
                send(waiting_room, {:enqueue, pid_c, self()})

                receive do
                    :added -> send(barber, :customer_waiting)
                end

                receptionist(waiting_room)
            end
    end


    # barber
    def barber(waiting_room) do
        receive do
            :customer_waiting ->
                send(waiting_room, {:dequeue, self()})

                receive do
                    {:ok, customer} ->
                        IO.puts("Barber is cutting hair for customer #{inspect(customer)}")
                        random_number = :rand.uniform(9)    # random number between 1 and 9
                        :timer.sleep(1000*random_number)
                        send(customer, :done)
                        SleepingBarber.barber(waiting_room);

                    :empty ->
                        IO.puts("No customer in the queue. Barber is going to sleep.")
                        SleepingBarber.barber(waiting_room);
                end
        end
    end


    def customer(receptionist) do
        send(receptionist, {:receptionist, self()})

        receive do
            :wait -> IO.puts("Customer #{inspect(self())} is waiting.")
            :full -> IO.puts("Customer #{inspect(self())} left, no space in the queue.")
            :done -> IO.puts("Customer #{inspect(self())} got a haircut and left.")
        end
    end





    # def enqueue(pid_wr, pid_c) do send( pid_wr, {:enqueue, pid_c}) end
    # def dequeue(pid) do send(pid, {:dequeue}) end
    # def size(pid) do
    #     send(pid, {:size, self()})
    #     receive do {:ok, size} -> size end
    # end
    # def top(pid) do
    #     send(pid,{:top, self()})
    #     receive do {:ok,item} -> item end
    # end

    # customer waiting room
    def waiting_room(queue) do
        receive do
            {:enqueue, pid_c, sender} ->
                if Enum.count(queue) >= 6 do
                    send(pid_c, :full)
                    waiting_room(queue)
                else
                    send(sender, :added)
                    waiting_room(queue ++ [pid_c])
                end
            {:dequeue, sender} ->
                case queue do
                    [customer | others] ->
                        send(sender, {:ok, customer})
                        waiting_room(others)

                    [] ->
                        send(sender, :empty)
                        waiting_room(queue)
                end

            # {:top, sender} ->
            #     if queue == [] do send(sender, {:ok, nil})
            # else send(sender, {:ok, hd(queue)})
            # end
            # waiting_room(queue)
            # {:size, sender} ->
            #     send(sender, {:ok, Enum.count(queue)})
            #     waiting_room(queue)
        end
    end
end
