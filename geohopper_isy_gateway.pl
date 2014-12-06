#!/usr/bin/env perl

#
# Author:       Sagi Geva - sagi.geva@icloud.com
# Project:      Geohopper ISY Home Automation Gateway
# Version:      0.3
# Date:			05 Dec 2014
#


use Mojolicious::Lite;
use Data::Dumper;
use LWP::UserAgent;


### DEFINE ISY CONNECTION PARAMETERS ###

my %isy_params = (
	
	'address' => '192.168.0.20',
	'port' => '80',
	'user' => 'admin',
	'pass' => 'yourpassword',
	
);
	

### DEFINE GEOHOPPER LOCATION NAMES AND MATCHING ISY VAR IDS (LOCATION NAMES ARE CASE SENSITIVE) ###

my %isy_locations = (
	
	'Master Bedroom' => '27',
	'House Entrance' => '26',
	'Car' => '42',
	'Office' => '38',
	
);


### DEFINE AUTHORIZED USER(S), ADD AS MANY AS YOU WANT ###

my %authorized = (

	1 => 'someone@icloud.com',
	2 => 'someone2@gmail.com',
		
);


### DEFINE VAR VALUES FOR EACH EVENT TYPE ###

my %event_value = (

	'Enter' => '1',
	'Exit' => '0',
	'Test' => '2',

); 


### UPDATE ISY VAR ###

sub update_isy_var {

	my $browser = LWP::UserAgent->new;
	my $req =  HTTP::Request->new(GET => "http://$isy_params{'address'}:$isy_params{'port'}/rest/vars/set/2/$isy_locations{$_[0]}/$event_value{$_[1]}");
	$req->authorization_basic("$isy_params{'user'}", "$isy_params{'pass'}");
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
	
    $self->app->log->debug(@data);
	
    
    my $sender = substr($data[0], 7);
    my $location = substr($data[1], 9);
    my $event = substr($data[2], 14);
	
    
	### CHECK IF USER IS AUTHORIZED ###

    if (grep {$sender eq $_} values %authorized)  {

        $self->res->headers->header( 'Content-Type' => 'text/html' );


		### VERIFY LOCATION AND UPDATE ISY VAR ###
       
        if (grep {$location eq $_} keys %isy_locations) {

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
app->log->level('debug');
app->start;