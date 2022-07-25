# README

This README would normally document whatever steps are necessary to get the
application up and running.

* Ruby version 3.0.2 on production servers. Only 3.1.2 is available locally so reset after pull

* Uses delayed_job to process background MCO stuff

* Notes about deployment

  For "production" environment the asset pipeline is currently misconfigured and does not work 
  properly. As a temporary workaround, run the prod instance in RAILS_ENV=prodcution_dev. This runs with
  production settings but without needing to precompile assets.

  For "test" instance on our infrastructure, run RAILS_ENV=test_dev. There is a bug in Rails that
  stomps on anything you set for 
  config.active_job.queue_adapter = :delayed_job 
  which prevents delayed_job ActiveJobs from queuing. This bug only impacts the Rails "test" environment
  so test_dev is a workaround for this.