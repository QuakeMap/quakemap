env :PATH, ENV['PATH']

every 1.minute do
  rake 'quake:pull_rapid'
end

every 2.minutes do
  rake 'quake:pull_felt'
end
