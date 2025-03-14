defmodule sleeping_barber do

# for each customer
def new do
    pid =  spawn_link(__MODULE__, :loop, [[]])
    {:ok, pid}
end

def enqueue(pid, item) do send( pid, {:enqueue, item}) end
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
        {:enqueue, item} ->
            waiting_room([queue|item])
        {:dequeue} ->
            if queue == [] do loop(queue) end
            loop(tl(queue))
        {:top, sender} ->
            if queue == [] do send(sender, {:ok, nil})
        else send(sender, {:ok, hd(queue)})
        end
        loop(queue)
        {:size, sender} ->
            send(sender, {:ok, Enum.count(queue)})
            loop(queue)
    end
end

end
