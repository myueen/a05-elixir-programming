defmodule sleeping_barber do

# for each customer
def new do
    pid_wr =  spawn_link(__MODULE__, :waiting_room, [[]])
    pid_r =  spawn_link(__MODULE__, :receptionist, [[]])
    pid_b =  spawn_link(__MODULE__, :barber, [[]])
    loop(pid_wr, pid_r)
    {:ok, pid}
end

def loop(pid_wr, pid_r) do
    pid_c =  spawn_link(__MODULE__, :customer, [[]])
    send(pid_r, {:receptionist, pid_wr, pid_c})
    random_number = :rand.uniform(9)    # random number between 1 and 9
    :timer.sleep(1000*random_number)
    loop(pid_wr, pid_r)
end



# receptionist
def receptionist() do
    receive do
        {:receptionist, pid_wr, pid_c} ->
            IO.puts("Greeting #{inspect(pid_c)}")
            enqueue(pid_wr, pid_c)
            receptionist()
        end
end


# barber
def barber(pid) do
    if queue != [] do dequeue(pid) end
    # print random time

end

def enqueue(pid_wr, pid_c) do send( pid_wr, {:enqueue, pid_c}) end
def dequeue(pid) do send (pid,{:dequeue}) end
def size(pid) do
    send(pid, {:size, self()})
    receive do {:ok, size} -> size end
end
def top(pid) do
    send(pid,{:top, self()})
    receive do {:ok,item} -> item end
end

# customer waiting room
def waiting_room(queue) do
    receive do
        {:enqueue, pid_c} ->
            if Enum.count(queue) >= 6 do waiting_room(queue) end
            waiting_room([queue|pid_c])
        {:dequeue} ->
            if queue == [] do waiting_room(queue) end
            waiting_room(tl(queue))
        {:top, sender} ->
            if queue == [] do send(sender, {:ok, nil})
        else send(sender, {:ok, hd(queue)})
        end
        waiting_room(queue)
        {:size, sender} ->
            send(sender, {:ok, Enum.count(queue)})
            waiting_room(queue)
    end
end

end
