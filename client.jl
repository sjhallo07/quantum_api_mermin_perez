using Sockets
client = connect("/tmp/quantum_kernel.sock")
write(client, "8e8591b5c4e84428\n")
println(readline(client))
close(client)
