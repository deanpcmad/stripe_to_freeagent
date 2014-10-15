role :app, %w{deploy@s2f.voupe.com}
role :web, %w{deploy@s2f.voupe.com}
role :db,  %w{deploy@s2f.voupe.com}

role :resque_worker, "deploy@s2f.voupe.com"
role :resque_scheduler, "deploy@s2f.voupe.com"