MONGO = uri = ENV['MONGOHQ_URL'] || "mongodb://localhost/tesis_paula"
MongoMapper.config = { Rails.env => { 'uri' => uri } }
MongoMapper.connect(Rails.env)