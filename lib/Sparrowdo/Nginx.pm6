use v6;

unit module Sparrowdo::Nginx;

use Sparrowdo;

constant NGINX_TMPL = %?RESOURCES<default.conf>.Str;

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
    task => "set up nginx site",
    plugin => "templater",
    parameters => %(
      variables => %(),
      target  => ( target_os() ~~ m/centos/ ) ?? '/etc/nginx/conf.d/default.conf' !! '/etc/nginx/sites-enabled/default',
      mode    => '644',
      source => slurp NGINX_TMPL
    )
  );

  task_run  %(
    task => 'start nginx',
    plugin => 'service',
    parameters => %( service => 'nginx', action => 'restart' )
  );


}

