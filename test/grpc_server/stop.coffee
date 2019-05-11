
parameters = require '../../src'

describe 'grpc.stop', ->
  
  it 'return false unless started', ->
    app = parameters
      grpc:
        address: '0.0.0.0'
        port: 50051
    status = await app.grpc_stop()
    status.should.be.false()
