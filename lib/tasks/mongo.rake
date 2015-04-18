namespace :db do
  namespace :test do
    task :prepare do
      MongoMapper.database.collections.each do |coll|
        coll.remove
      end
    end
  end
end
