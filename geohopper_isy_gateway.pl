#!/usr/bin/env perl

#
# Author:       Sagi Geva - sagi.geva@icloud.com
# Project:      Geohopper ISY Home Automation Gateway
# Version:      0.5
# Date:			06 Dec 2014
#


use Mojolicious::Lite;
use Data::Dumper;
use LWP::UserAgent;
use Config::Simple;


my %config;
Config::Simple->import_from('geohopper_isy_gateway.cfg', \%config);


### UPDATE ISY VAR ###

sub update_isy_var {

	my $browser = LWP::UserAgent->new;
	my $req =  HTTP::Request->new(GET => "http://$config{'isy.address'}:$config{'isy.port'}/rest/vars/set/2/$config{\"location.$_[0]\"}/$config{\"event.$_[1]\"}");
	$req->authorization_basic("$config{'isy.user'}", "$config{'isy.pass'}");
	my $reply = $browser->request($req);
	return $reply;

}


get '/' => sub {
	
    my $self = shift;
    $self->render( text => "Geohopper ISY gateway is online" );
	
};


post '/geohopper' => sub {
	
	
	### PARSE GEOHOPPER MESSAGE ###

    my $self = shift;
    my $text = $self->req->text;
    $text =~ tr/"{}//d; 
    my @data = split(/,/, $text);
	
    $self->app->log->debug(%config);
	
    my $sender = substr($data[0], 7);
    my $location = substr($data[1], 9);
    my $event = substr($data[2], 14);
	
	
	    
	### CHECK IF USER IS AUTHORIZED ###

    if (grep {/$sender/i} values %config)  {

        $self->res->headers->header( 'Content-Type' => 'text/html' );
		

		### VERIFY LOCATION AND UPDATE ISY VAR ###
       
        if (grep {/$location/i} keys %config) {
			
			update_isy_var($location,$event);
			
            $self->app->log->info("User: $sender. Location: $location. Event: $event");        	
			$self->render( text => 'OK', status => 200 );

        }

        else {

            $self->app->log->info("Unknown Location");			
            $self->render( text => 'Not Implemented', status => 501 );

        }
    
	}
	
	else {
		
        $self->app->log->info("Unauthorized user: $sender");        
        $self->render( text => 'Forbidden', status => 403 );
    
    }

};

app->log->path('log/geohopper_isy_gateway.log');
app->log->level('info');
app->mode('production');
app->start;
