<?php
$config = array (
  'MISP' => 
  array (
    'system_setting_db' => true,
    'python_bin' => '/usr/local/bin/python3',
    'redis_host' => 'redis',
    'redis_password' => '',
    'redis_port' => 6379,
    'attachments_dir' => '/var/www/MISP/app/files',
    'background_jobs' => true,
    'ca_path' => '/etc/ssl/certs/ca-certificates.crt',
    'download_gpg_from_homedir' => false,
    'menu_custom_right_link' => '',
    'menu_custom_right_link_html' => '',
    'online_version_check' => true,
    'osuser' => 'www-data',
    'redis_database' => 13,
    'self_update' => false,
    'tmpdir' => '/var/www/MISP/app/tmp',
    'uuid' => '',
  ),
  'GnuPG' => 
  array (
    'binary' => '/usr/bin/gpg',
  ),
  'Security' => 
  array (
    'disable_instance_file_uploads' => false,
    'disable_local_feed_access' => false,
    'rest_client_enable_arbitrary_urls' => false,
    'salt' => 'OHzHKOc<zNaHQQbQg2v)wl1F^1O+gFJ(',
    'encryption_key' => '',
    'password_policy_length' => 12,
    'password_policy_complexity' => '/^((?=.*\\d)|(?=.*\\W+))(?![\\n])(?=.*[A-Z])(?=.*[a-z]).*$|.{16,}/',
    'auth' => 
    array (
    ),
  ),
  'Plugin' => 
  array (
    'ZeroMQ_redis_host' => 'redis',
    'ZeroMQ_redis_password' => '',
    'ZeroMQ_redis_port' => 6379,
    'ZeroMQ_enable' => false,
  ),
  'SimpleBackgroundJobs' => 
  array (
    'redis_host' => 'redis',
    'redis_password' => '',
    'redis_port' => 6379,
    'supervisor_host' => '127.0.0.1',
    'supervisor_password' => 'supervisor',
    'supervisor_user' => 'supervisor',
    'enabled' => true,
    'max_job_history_ttl' => 86400,
    'redis_database' => 1,
    'redis_namespace' => 'background_jobs',
    'supervisor_port' => 9001,
  ),
  'OidcAuth' => 
  array (
    'provider_url' => '',
    'issuer' => '',
    'client_id' => '',
    'client_secret' => '',
    'code_challenge_method' => '',
    'roles_property' => '',
    'role_mapper' => '',
    'default_org' => '',
  ),
  'Session' => 
  array (
    'timeout' => 60,
    'cookie_timeout' => 10080,
    'defaults' => 'php',
    'autoRegenerate' => false,
    'checkAgent' => false,
    'ini' => 
    array (
      'session.cookie_secure' => true,
      'session.cookie_domain' => '',
      'session.cookie_samesite' => 'Lax',
    ),
  ),
);