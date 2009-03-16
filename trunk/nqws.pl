#!/usr/bin/perl
#
# NQWS Client
# v0.2.0 beta
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
use Switch;

my $scriptVersion  = 'v0.2.0 beta';
my $autoOutputPath = '';

$|++; # autoflush
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
		  $ascii > 122)
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
	
	my $httprequest  = "GET ".$path." HTTP/1.0\r\n";
	$httprequest    .= "Host: ".$host."\r\n";
	$httprequest    .= "Dev-pwd: ".$oe."tsk01\r\n";
	$httprequest    .= "User-Agent: NQWS Client\r\n";
	$socket->send($httprequest."\r\n");
	
	my $response = '';	
	while(defined (my $buffer = <$socket>)) { $response .= $buffer; }
	close($socket);
	
	return substr($response, index($response, "\r\n\r\n") + length("\r\n\r\n"));
}

sub getRemoteFileSize()
{
	my $host = shift;
	my $path = shift;

	my $socket = IO::Socket::INET->new(PeerAddr => $host, PeerPort => 80);
	return 0 unless $socket;
	
	my $httprequest	 = "HEAD ".$path." HTTP/1.0\r\n";
	$httprequest    .= "Host: ".$host."\r\n";
	$httprequest    .= "User-Agent: NQWS Client\r\n";
	$socket->send($httprequest."\r\n");
	
	my $response = '';
	while(defined (my $buffer = <$socket>)) { $response .= $buffer; }
	close($socket);
	
	lc($response) =~ m/content-length:\s?([0-9]*)/;
	
	return $1;
}

sub download()
{
	my $host       = shift;
	my $path       = shift;
	my $size       = shift;
	my $outputPath = shift;
	
	print "\nStarting download for http://".$host.$path." (".$size." octet(s))\n";
	print "Output path defined has '".$outputPath."'\n\n";
	print "[+] Connecting to ".$host."... ";
	
	my $socket = IO::Socket::INET->new(PeerAddr => $host, PeerPort => 80);
	die "[FAILED]\nCan't connect to ".$host." !\n" unless $socket;
	
	print "[OK]\n[+] Sending request data... ";	
	my $httprequest	 = "GET ".$path." HTTP/1.0\r\n";
	$httprequest    .= "Host: ".$host."\r\n";
	$httprequest    .= "User-Agent: NQWS Client\r\n";
	$socket->send($httprequest."\r\n");
	
	print "[OK]\n[+] Receiving data...   0%";	
	my $contentLength = 0;
	my $content = '';
	my $pc = 0;
	
	while(defined (my $buffer = <$socket>))
	{
		$content .= $buffer;
		
		print "\b\b\b\b";
		
		$pc = int(length($content) / $size * 100);
		if($pc < 100) { print " "; }
		if($pc < 10) { print " "; }
		print $pc."%";
	}
	close($socket);

	print "\b\b\b\b";		
	print "[OK]\n[+] Download complete\n[+] Writing file... ";
	
	open(FILE,">".$outputPath);
	print FILE $content;
	close(FILE);
	
	print "[OK]\n\nEnjoy listening :)\n\n";
	
	exit();
}

sub getHTTPCode()
{
	my $host = shift;
	my $path = shift;
	
	my $socket = IO::Socket::INET->new(PeerAddr => $host, PeerPort => 80);
	return '0' unless $socket;
	
	my $httprequest	 = "HEAD ".$path." HTTP/1.0\r\n";
	$httprequest    .= "Host: ".$host."\r\n";
	$httprequest    .= "User-Agent: NQWS Client\r\n";
	$socket->send($httprequest."\r\n");
	
	my $response = '';	
	while(defined (my $buffer = <$socket>)) { $response .= $buffer; }
	close($socket);
	
	$response =~ m/\s([0-9]{3})\s/;
	
	return $1;
}

sub getVTypeLevel()
{
	my $vType = shift;
	switch(lc($vType))
	{
		case m/alpha[0-9]*/   { return 1; }
		case m/beta[0-9]*/    { return 2; }
		case m/rc[0-9]*/      { return 3; }
		case m/release[0-9]*/ { return 4; }
		else                  { return 0; }
	}
}

sub isHigherVersion()
{
	my $remoteVersion = shift;
	my $localVersion  = shift;
	
	$remoteVersion =~ m/v?(.[^\s]*)\s*(.*)/;
	$remoteVersion = $1;
	my $remoteType = $2 ? lc($2) : 'release';
	
	$localVersion =~ m/v?(.[^\s]*)\s*(.*)/;
	$localVersion = $1;
	my $localType = $2 ? lc($2) : 'release';
	
	if($remoteVersion gt $localVersion) { return 1; }
	if($localVersion gt $remoteVersion) { return 0; }
		
	if(&getVTypeLevel($remoteType) > &getVTypeLevel($localType)) { return 1; }
	if(&getVTypeLevel($localType) > &getVTypeLevel($remoteType)) { return 0; }
	
	return 0;
}

sub getRemoteLastVersion()
{
	my $svnTagsPage = reverse &openurl('nqws.googlecode.com', '/svn/tags/');
	$svnTagsPage =~ m/a\/<\/(.[^>]*)>"/;
	return reverse $1;
}

sub updateScript()
{
	my $version = shift;
	my $path    = '/svn/tags/'.$version.'/nqws.pl';
	
	print "\nLook for an existing script of NQWS Client ".$version."... ";
	
	if(&getHTTPCode('nqws.googlecode.com', $path) ne '200')
	{
		die "FAILED\nUnable to update NQWS Client to ".$version." !\n";
	}
	
	print "OK\nDownloading the script... ";
	
	my $newScript = &openurl('nqws.googlecode.com', $path);
	
	print "OK\nRewriting the script... ";
	
	open(FILE,">".__FILE__);
	print FILE $newScript;
	close(FILE);
	
	print "OK\n\nNQWS Client was updated to ".$version."\n";
	die "\nThanks for using my client script and NQuenault Web Services :)\n\n";
}

sub getXmlTag()
{
	my $xmlContent = shift;
	my $tagName    = shift;
	
	$xmlContent =~ m/<$tagName>(.[^>]*)<\/$tagName>/;
	return $1;
}

sub listServices()
{
	my $sresponse = &openurl('webservices.nquenault.fr', '/listservices.html');
	if(index($sresponse, "<title>404 Page Not Found</title>") ne - 1) { die "Service not found\n"; }
	die $sresponse."\n";
}

sub requestService()
{
	my ($service, $function, $arguments) = @_;
	my $path = "/services/".$service.
	   ($function ? "/".$function : "/index").
	   ($arguments ? "/".&encodeArgs($arguments) : '').
	   ".html";
	   
	my $socket = IO::Socket::INET->new(PeerAddr => 'webservices.nquenault.fr', PeerPort => 80);
	die "Can't connect to webservices.nquenault.fr !\n" unless $socket;
	
	my $httprequest  = "GET ".$path." HTTP/1.0\r\n";
	$httprequest    .= "Host: webservices.nquenault.fr\r\n";
	$httprequest    .= "User-Agent: NQWS Client\r\n";
	$socket->send($httprequest."\r\n");
	
	my $sresponse = '';
	my $headers = '';
	my $bodyPart = 0;
	while(defined (my $buffer = <$socket>))
	{
		if($bodyPart == 0)
		{
			$headers .= lc($buffer);
			if(index($headers, "\r\n\r\n") ne -1) { $bodyPart = 1; }
		}
		else
		{
			if(index($headers, "flow: continue\r\n") ne -1) { print $buffer; }
			else { $sresponse .= $buffer; }
		}
	}
	close($socket);

	if(index($sresponse, "<title>404 Page Not Found</title>") ne - 1)
	{
		die "Service not found\n";
	}

	my $command = &getXmlTag($sresponse, 'command');
	if($command ne '')
	{
		switch($command)
		{
			case 'download'
			{
				my $host = &getXmlTag($sresponse, 'host');
				my $path = &getXmlTag($sresponse, 'path');
				my $size = &getXmlTag($sresponse, 'size');
				if($size eq '') { $size = &getRemoteFileSize($host, $path); }
				
				my $outputPath = '';
				if($autoOutputPath eq '')
				{
					print "\nNQWS Server has returned a file to download (".$size." octet(s)) :\n";
					print "http://".$host.$path."\n\n";
					print "Enter an output path or type 'cancel' : ";
					chop($outputPath = <STDIN>);
				}
				else { $outputPath = $autoOutputPath; }
				
				if($outputPath ne 'cancel') { &download($host, $path, $size, $outputPath); }
				else { die "File download have been canceled\n"; }
			}
		}
	}
	else { print $sresponse."\n"; }
	
	exit();
}

sub checkForNewerVersion()
{
	my $remoteVersion = &getRemoteLastVersion();
	if(&isHigherVersion($remoteVersion, $scriptVersion) == 1)
	{
		print "\nNQWS Client ".$remoteVersion." is available !\n";
		print "Want you to update the client script ? [y/n] ";
		chop(my $response = <STDIN>);
		if($response eq 'y' || $response eq 'yes' || $response eq 'o')
		{
			&updateScript($remoteVersion);
		}
		exit();
	}
	
	die "You have the lastest version of NQWS Client\n";
}

sub usage()
{
	print "\nnqws client ".$scriptVersion."\n";
	print "usage: ".$0." [OPTION...] [SERVICE [FUNCTION [ARGUMENTS]]]\n\n";
	print " options:\n";
	print "\t--help; -h:\tprint this message\n";
	print "\t--list; -l:\tlist availables services on the server\n";
	print "\t--check; -c:\tcheck for a newer version of NQWS Client\n";
	print "\t--update; -u:\tdownload the last version of NQWS Client\n";
	print "\t--output; -o:\tset an auto output file path for download\n";
	print "\t--spath; -p:\tshow the url for the service to use with Firefox\n";
	die "\n";
}

if(@ARGV < 1 || (@ARGV >= 1 && (
   $ARGV[0] eq '--help' ||
   $ARGV[0] eq '-h'
))) { usage; }

my $option = shift;

if($option eq '--update' || $option eq '-u') { updateScript; }
if($option eq '--list'   || $option eq '-l') { listServices; }
if($option eq '--check'  || $option eq '-c') { checkForNewerVersion; }
if($option eq '--output' || $option eq '-o') { $autoOutputPath = shift; $option = shift; }
if($option eq '--spath'  || $option eq '-p') {
	my $service   = shift;
	my $function  = shift;
	my $arguments = join(' ', @ARGV);
	print "Path : http://webservices.nquenault.fr/services/".$service.
	   ($function ? "/".$function : "/index").
	   ($arguments ? "/".&encodeArgs($arguments) : '').
	   ".html\n";
	exit;
}

if(substr($option, 0, 1) eq '-')
{
	die $option." is not a valid option on NQWS Client !\n";
}

my $service   = $option;
my $function  = shift;
my $arguments = join(' ', @ARGV);

&requestService($service, $function, $arguments);

