#!/usr/bin/env ruby
# encoding: utf-8

require 'bunny'
require 'colorize'
require 'json'

conn = Bunny.new(hostname: "210.118.69.58", vhost: "tongsu-vhost", user: "tongsu", password: "12341234")
conn.start

ch   = conn.create_channel
x    = ch.topic("tongsu")
q    = ch.queue("stmp_user", exclusive: true, durable: true)

q.bind(x, routing_key: "To.Postfix.#")

puts " [*] INFO " + "통통거리노- Postfix Client".colorize(color: :red) + " 1.0.0"
puts " [*] INFO Client::Postfix#Start: pid=#{Process.pid}"

begin
  q.subscribe(block: true) do |delivery_info, properties, body|
    puts " [x] INFO #{delivery_info.routing_key}:#{body}"
    keys = delivery_info.routing_key.split(".")

    if "Web".eql? keys[3]
      if "User".eql? keys[4]
        hash =  JSON.parse(body)
        if "Create".eql? keys[5]
          `./user --adduser #{hash["user_id"]}`
        elsif "Destroy".eql? keys[5]
          `./user --deluser #{hash["user_id"]}`
        end
      end
    end
    
    if delivery_info.routing_key.include?("Send.Mail")
      f = File.new("/tmp/sendmail_tmp.txt", "w")
      f.write(body)
      f.close

      `sendmail -t < /tmp/sendmail_tmp.txt`
    end
  end
rescue Interrupt => _
  ch.close
  conn.close
end
