 namespace :quake do

   # task :pull_latest => [:environment] do

   #   last_quake = Quake.all().sort(strike_time: -1).first
   #   if last_quake
   #     start_time = last_quake.strike_time
   #   else
   #     start_time = Time.now - 7.days
   #   end
   #   end_time = Time.now

   #   Quake.pull_data(start_time,end_time)

   #   ["/public/index.html", "/public/recent.rss","/public/chch-222.html", '/public/chch-13-5.html'].each do |cache_page|
   #     cache_page = File.join(Rails.root, cache_page)
   #     File.delete(cache_page) if File.exists?(cache_page)
   #   end
   # end

   # task :pull_last_48_hours => [:environment] do
   #  start_time = Time.now - 48.hours
   #  end_time = Time.now
   #  Quake.pull_data(start_time,end_time)
   #  ["/public/index.html", "/public/recent.rss","/public/chch-222.html", '/public/chch-13-5.html'].each do |cache_page|
   #     cache_page = File.join(Rails.root, cache_page)
   #     File.delete(cache_page) if File.exists?(cache_page)
   #  end
   # end
  desc "Pull Latest Quakes from GeoNet Webservice"
  task :pull_rapid => [:environment] do
    Quake.pull_rapid
  end

  desc "Pull Felt Quakes from GeoNet Webservice"
  task :pull_felt => [:environment] do
    Quake.pull_felt
  end

 end
