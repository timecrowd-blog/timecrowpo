Rails.application.config.middleware.use OmniAuth::Builder do
  provider :timecrowd,
           ENV['TIMECROWD_APP_ID'],
           ENV['TIMECROWD_SECRET'],
           client_options: { site: 'https://timecrowd.net' }
end
OmniAuth.config.failure_raise_out_environments = []
OmniAuth.config.logger = Rails.logger
