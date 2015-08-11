#!/usr/bin/env ruby
# encoding: utf-8

require 'bunny'
require 'colorize'
require 'json'

conn = Bunny.new(hostname: "210.118.69.43", vhost: "tongsu", user: "postfix", password: "1234")
conn.start

ch   = conn.create_channel
x    = ch.topic("tongsu")
q    = ch.queue("", exclusive: true)

q.bind(x, routing_key: "To.Postfix.#")

puts " [*] INFO " + "통통거리노- Postfix Client".colorize(color: :red) + " 1.0.0"
puts " [*] INFO Client::Postfix#Start: pid=#{Process.pid}"

begin
  q.subscribe(block: true) do |delivery_info, properties, body|
    puts " [x] INFO #{delivery_info.routing_key}:#{body}"
    keys = delivery_info.routing_key.split(".")
    hash =  JSON.parse(body)

    if "Web".eql? keys[3]
      if "User".eql? keys[4]
        if "Create".eql? keys[5]
          `/home/mailing/postfix/postfix/src/custom/user --adduser #{hash["uid"]}`
        elsif "Destroy".eql? keys[5]
          `/home/mailing/postfix/postfix/src/custom/user --deluser #{hash["uid"]}`
        end
      end
    elsif "Bigdata".eql? keys[3]
    end
  end
rescue Interrupt => _
  ch.close
  conn.close
end
