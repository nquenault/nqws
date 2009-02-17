#! /usr/bin/perl

use strict;
use IO::Socket;

my $version = 0.1.15;

sub prepurl()
{
	my $url = $_[0];
	$url =~ s/ /%252520/g;
	$url =~ s/\./%25252e/g;
	return $url;
}

sub updateScript()
{
	my $socket = IO::Socket::INET->new(
		PeerAddr		=> 'nqws.googlecode.com:http(80)'
	);
	die "Can't connect to GoogleCode server !\n" unless $socket;
	
	$socket->send("GET /svn/trunk/nqws.pl HTTP/1.0\r\nHost: nqws.googlecode.com\r\n\r\n");
	
	my $response = '';	
	while(defined (my $buffer = <$socket>)) { $response .= $buffer; }
	close($socket);
	my $newScript = substr($response, index($response, "\r\n\r\n") + length("\r\n\r\n"));
	
	open(FILE,">".__FILE__);
	print FILE $newScript;
	close(FILE);
	
	exit();
}

sub listServices()
{
	my $socket = IO::Socket::INET->new(
		PeerAddr		=> 'webservices.nquenault.fr:http(80)'
	);
	die "Can't connect to NQWS's server !\n" unless $socket;
	
	$socket->send("GET /listservices.html HTTP/1.0\r\nHost: webservices.nquenault.fr\r\n\r\n");
	
	my $response = '';	
	while(defined (my $buffer = <$socket>)) { $response .= $buffer; }
	close($socket);
	my $sresponse = substr($response, index($response, "\r\n\r\n") + length("\r\n\r\n"));
	
	if(index($sresponse, "<title>404 Page Not Found</title>") ne - 1)
	{
		die "Service not found\n";
	}

	die $sresponse;
}

sub requestService()
{
	my ($service, $function, $arguments) = @_;
	my $path = "/services/".$service."/".
		($function ? "/".$function : "/index").
		($arguments ? "/".&prepurl($arguments) : '').
	".html";

	my $socket = IO::Socket::INET->new(
		PeerAddr		=> 'webservices.nquenault.fr:http(80)'
	);
	die "Can't connect to NQWS's server !\n" unless $socket;
	$socket->send('GET '.$path." HTTP/1.0\r\nHost: webservices.nquenault.fr\r\n\r\n");
	
	my $response = '';	
	while(defined (my $buffer = <$socket>)) { $response .= $buffer; }
	close($socket);
	my $sresponse = substr($response, index($response, "\r\n\r\n") + length("\r\n\r\n"));
	
	if(index($sresponse, "<title>404 Page Not Found</title>") ne - 1)
	{
		die "Service not found\n";
	}

	die $sresponse."\n";
}

sub usage()
{
	print __FILE__." [service] [function] [arguments]\n";
	print __FILE__." [service] usage\n";
}

if(@ARGV < 1 || (@ARGV >= 1 && $ARGV[0] eq '--help'))
{
	usage;
	exit();
}

if($ARGV[0] eq 'update')
{
	updateScript;
}

if($ARGV[0] eq 'list')
{
	listServices;
}

my ($service, $function, $arguments) = @ARGV;
&requestService($service, $function, $arguments);

exit();

