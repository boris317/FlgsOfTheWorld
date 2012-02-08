MongoMapper.connection = Mongo::Connection.new('127.0.0.1', 27017)
MongoMapper.database = "flgs-stores"

if defined?(PhusionPassenger)
   PhusionPassenger.on_event(:starting_worker_process) do |forked|
     MongoMapper.connection.connect if forked
   end
end