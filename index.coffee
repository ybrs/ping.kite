###
#
#  ping Kite for Koding
#  Author: devrim 
#
#  This is an example kite with two methods:
#
#    - helloWorld
#    - fooBar
#
###
kite     = require "kite-amqp/lib/kite-amqp/kite.coffee"
manifest = require "./manifest.json"

pinger = kite.worker manifest,

  consumeque:(options, callback)->
    console.log "options", options
    if callback
      @db.hset "pinger_processed", "#{options.args[0]}", 1, ()->
        callback(false, "#{options.args[0]} processed")

  pong: (options, callback)->
    console.log "received pong"
    console.log "options", arguments
    console.log "sender", options.from
    console.log "now pinging the sender"
    # this sends a ping request to the sender only
    # and then sender broadcasts pong request...
    @one options.from, "ping", [], (err, r)->
      console.log "sent ping"

  ping: (options, callback)->
    # this sends a pong request to everyone...
    @everyone "pong", [options], (reply)->
      console.log "here", reply
    callback()

  start: (options, callback)->
    for i in [1..3]
      console.log ">>> ", i
      @queue "consumeque", ["worldx_#{i}"], (err, ret)->
        console.log "queue command returned", arguments
  , true
  #   @everyone "ping", [options], (reply)->
  #     console.log "here", reply
  # , true

pinger.on 'running', ()->
  pinger.call 'start', [], ()->
    console.log "started"
    #process.exit 0

pinger.on 'ready', ()->
  pinger.run()


