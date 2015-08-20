#!usr/bin/env ruby
# encoding: utf-8

require 'bunny'
require 'socket'			   # Get sockets from stdlib

conn = Bunny.new(hostname: "210.118.69.43", vhost: "tongsu", user: "webmail", password: "1234")
conn.start

ch   = conn.create_channel
x    = ch.topic("tongsu")
# q    = @ch.queue("", exclusive: true)
# q.bind(x, routing_key: "From.Postfix.#")
          
server = TCPServer.new(28561)  # Socket to listen on port 2000
loop {                         # Servers run forever
    						   # Wait for a client to connect
	puts "#### smtp-client.rb start ####"
	Thread.start(server.accept) do |client|
		msg = ""
		while line = client.gets
			msg += line
		end
		client.close            # Disconnect from the client
		x.publish("#{msg}", routing_key: "From.Postfix.Receive.Mail", persistent: true)
		puts " [x] Sent #{msg}"
	end
}

ch.close						# Disconnect channel
conn.close						# Disconnect connection
