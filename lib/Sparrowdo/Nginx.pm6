use v6;

unit module Sparrowdo::Nginx;

use Sparrowdo;

constant NGINX_MAIN_TMPL = %?RESOURCES<nginx.conf>.Str;
constant NGINX_DEFAULT_TMPL = %?RESOURCES<default.conf>.Str;

our sub tasks (%args) {

  if target_os() ~~ m/centos/ {

    task_run  %(
      task => 'install epel-release',
      plugin => 'package-generic',
      parameters => %( list => 'epel-release' )
    );
  
  }

  task_run  %(
    task => 'install nginx',
    plugin => 'package-generic',
    parameters => %( list => 'nginx' )
  );

  task_run  %(
    task => 'enable nginx',
    plugin => 'service',
    parameters => %( service => 'nginx', action => 'enable' )
  );


  task_run %(
    task => "set up nginx main config",
    plugin => "templater",
    parameters => %(
      variables => %( user => ( target_os() ~~ m/centos/ ) ?? 'nginx' !! 'www-data' ),
      target  => '/etc/nginx/nginx.conf',
      mode    => '644',
      source => slurp NGINX_MAIN_TMPL
    )
  );

  task_run %(
    task => "set up nginx default site",
    plugin => "templater",
    parameters => %(
      variables => %(),
      target  => ( target_os() ~~ m/centos/ ) ?? '/etc/nginx/conf.d/default.conf' !! '/etc/nginx/sites-enabled/default',
      mode    => '644',
      source => slurp NGINX_DEFAULT_TMPL
    )
  );

  task_run %(
    task    => "check nginx config",
    plugin  => "bash",
    parameters => %(
      command => "nginx -t"
    )
  );

  task_run  %(
    task => 'start nginx',
    plugin => 'service',
    parameters => %( service => 'nginx', action => 'restart' )
  );


}

