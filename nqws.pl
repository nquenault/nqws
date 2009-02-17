#! /usr/bin/perl
#
# NQWS Client
# <scriptVersion>0.1.16</scriptVersion>
#
# written by Nicolas Quenault
#
# Please send bugs, feedbacks and code reviews to nquenault(at)gmail.com
#
# Homepage	: http://nqws.googlecode.com/
# Blog		: http://www.nquenault.fr/
#

use strict;
use IO::Socket;

my $scriptVersion = '0.1.16';
my $scriptType		= 'beta';

sub encodeArgs()
{
	my $argument = shift;
	
	$argument =~ s/^\s+//; $argument =~ s/\s+$//;
	my @argument = split '', $argument;
	
	my $encodedArg = '';
	for(my $i=0;$i<@argument;$i++)
	{
		my $ascii = ord $argument[$i];
		if($ascii < 48 ||
			($ascii > 57 && $ascii < 65) ||
			($ascii > 90 && $ascii < 97) ||
			$ascii > 121)
		{ $encodedArg .= '%2525'.sprintf "%02x", $ascii; }
		else { $encodedArg .= $argument[$i]; }
	}

	return $encodedArg;
}

sub openurl()
{
	my $host = shift;
	my $path = shift;

	my $socket = IO::Socket::INET->new(PeerAddr => $host, PeerPort => 80);
	die "Can't connect to ".$host." !\n" unless $socket;
	
	$socket->send("GET ".$path." HTTP/1.0\r\nHost: ".$host."\r\n\r\n");
	
	my $response = '';	
	while(defined (my $buffer = <$socket>)) { $response .= $buffer; }
	close($socket);
	
	return substr($response, index($response, "\r\n\r\n") + length("\r\n\r\n"));
}

sub updateScript()
{
	my $newScript = &openurl('nqws.googlecode.com', '/svn/trunk/nqws.pl');
	
	open(FILE,">".__FILE__);
	print FILE $newScript;
	close(FILE);
	
	exit();
}

sub listServices()
{
	my $sresponse = &openurl('webservices.nquenault.fr', '/listservices.html');
	if(index($sresponse, "<title>404 Page Not Found</title>") ne - 1)
		{ die "Service not found\n"; }

	die $sresponse;
}

sub requestService()
{
	my ($service, $function, $arguments) = @_;
	my $path = "/services/".$service."/".
		($function ? "/".$function : "/index").
		($arguments ? "/".&encodeArgs($arguments) : '').
		".html";

	my $sresponse = &openurl('webservices.nquenault.fr', $path);
	if(index($sresponse, "<title>404 Page Not Found</title>") ne - 1)
		{ die "Service not found\n"; }

	die $sresponse."\n";
}

sub usage()
{
	print "NQWS ".$scriptVersion." client\n\n";
	print $0." --help\n";
	print $0." list\n";
	print $0." [service] [function] [arguments]\n";
	print $0." [service] usage\n";
	exit();
}

if(@ARGV < 1 || (@ARGV >= 1 && $ARGV[0] eq '--help'))
{
	usage;
}

if($ARGV[0] eq 'list')
{
	listServices;
}

my ($service, $function, $arguments) = @ARGV;
&requestService($service, $function, $arguments);

exit();

