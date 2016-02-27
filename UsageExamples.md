# Some Services Usage Examples #

## Whois Service ##

help :
```
./nqws.pl whois
```

### Whois Query ###

command :
```
perl ./nqws.pl whois query <any domain>
```

As simple as this, just type in your prompt..<br />
```
./nqws.pl whois query google.com
```
..and the result of the whois data for google.com will appear :)

## MD5 and SHA1 Services ##

md5 help :
```
./nqws.pl md5
```
sha1 help :
```
./nqws.pl sha1
```

### MD5 and SHA1 Encryptions ###

md5 command :
```
./nqws.pl md5 encrypt <something to encrypt>
```
sha1 command :
```
./nqws.pl sha1 encrypt <something to encrypt>
```

As simple as using the whois service, you've just to type in your prompt something like..<br />
```
./nqws.pl md5 encrypt word
> c47d187067c6cf953245f128b5fde62a
```
.. or something like..<br />
```
./nqws.pl md5 encrypt a
> 0cc175b9c0f1b6a831c399e269772661
```
.. or something like..<br />
```
./nqws.pl sha1 encrypt I need u to encrypt me
> 5d9125ffa56b5fe41ec31fd66a516e9b3688ab0c
```

## MP3Download Service ##

mp3download help :
```
./nqws.pl mp3download
```

### MP3Download Get ###
**(working but available on the next release)**

mp3download command :
```
./nqws.pl mp3download get <keywords as artist and/or song title>
```
alternative mp3download command :
```
./nqws.pl -o ./output.mp3 mp3download get <keywords as artist and/or song title>
```

If you're looking for some mp3 quickly and easily, NQWS will enjoy you! for example..<br />
I'm looking for "Clubbed to Death" song title.. i will just type in my prompt..<br />
```
./nqws.pl mp3download get clubbed to death
>
> NQWS Server has returned a file to download (XXXXXX octet(s)) :
> http://www.host.com/path_to_the_mp3_file.mp3
>
> Enter an output path or type 'cancel' : ./mysong.mp3
>
> Starting download for http://www.host.com/path_to_the_mp3_file.mp3 (XXXXXX octet(s))
> Output path defined has './mysong.mp3'
>
> Connecting to www.host.com... OK
> Sending request data... OK
> Receiving data... OK
> Download complete
> Writing file... OK
>
> Enjoy listening :)
>
```
If you want to directly download the mp3 in a file, you can set the argument --output (or -o) in the command like..<br />
```
./nqws.pl --output ./mysong.mp3 mp3download get clubbed to death
>
> Starting download for http://www.host.com/path_to_the_mp3_file.mp3 (XXXXXX octet(s))
> Output path defined has './mysong.mp3'
>
> Connecting to www.host.com... OK
> Sending request data... OK
> Receiving data... OK
> Download complete
> Writing file... OK
>
> Enjoy listening :)
>
```

## OpenURL Service ##
**(working but available on the next release)**

openurl help :
```
./nqws.pl openurl
```

### OpenURL Get/Head/Body ###

openurl command :
```
./nqws.pl openurl get <any url you want>
```