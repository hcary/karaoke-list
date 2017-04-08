#!/usr/bin/perl


use Getopt::Long;
use POSIX;
use File::Find;
use Data::Dumper;

my $myTitle = 0;
my $myArtist = 1;
$count = 0;

use constant false => 0;
use constant true  => 1;

#
my $fout = "test.csv";
my $artist_out = "artists.txt";
my $artist_db = "artists.db";
my $sql_out = "songlist.sql";

GetOptions (
    "i|input=s"   	=> \$filename,
    "o|output=s"    => \$fout,
    "a|artist=s"    => \$artist_out,
    "s|search=s"    => \$search
);

sub clean_string {

    my $str = shift(@_);
    
    $str =~ s/\(/_/g;
    $str =~ s/\)/_/g;
    $str =~ s/'/_/g;
    $str =~ s/,/_/g;
    $str =~ s/^"//g;
    $str =~ s/ /_/g;
    $str =~ s/__/_/g;
    $str =~ s/_$//g;
    $str =~ s/Wvocal//g;
    $str =~ s/\&/and/g;
    $str =~ s/Christiina/Christina/g;
    return $str;
    
} #sub clean_string

sub clean_vocal {
    
    my $str = shift(@_);
    
    $str =~ s/^"//g;
    return $str;
    
} #sub clean_vocal

open($fh, "<", $filename) or die "Unable to open $filename for output\n";
open($ao, ">", $artist_out) or die "Unable to open $artist_out for output\n";
open($oh, ">", $fout) or die "Unable to open $fout for output\n";
open($sqlo, ">", $sql_out) or die "Unable to open $fout for output\n";

#
# Load artist db
open($DB, "<", $artist_db) or die  "Unable to open $artist_db for output\n";
while( my $line = <$DB> ) {
    push @artistDb, $line;
}
close $DB;


while( my $line = <$fh> ) {

    if ( $line =~ m/Vcl|Mpx|Wvocal|W Vocal|W-Vocal|Vocals|\(Vocal\)|\(Vocals\)| With Vocal|\(Vocal Version\)|\(Vocal Track\)|Wvoca|Wvoc|\(Voc\)|wvocal/) { next; }
    $line = clean_vocal($line);

    @data = split(/","/, $line);
 
    $str = $data[$myArtist];
    $str =~ s/  / /g;
    $str =~ s/^\s+|\s+$//g;
    $str =~ s/\ and\ /\ \&\ /g;
    if ( $str =~ /^the /i ) {
        $str =~ s/^the //i;
        $str = $str . ", The";
    }
    $artistName = $str;
    
    $tmpArtist = clean_string($str);
    
    if ( $tmpArtist eq "Vocal" ) { next; }

    if( length($data[$myArtist]) < 1 ) {
        print "Error: Artist name missing\n";
        print $data[$myArtist] . "\n";
    }

    $str = $data[$myTitle];
    $str =~ s/  / /g;
    $str =~ s/^\s+|\s+$//g;
    $str =~ s/\ and\ /\ \&\ /g;
    
    $titleName = $str;
    $tmpTitle = clean_string($str);
    if ( $tmpTitle eq "Vocal" ) { next; }
    
    $key = $tmpArtist . "_" . $tmpTitle;
    
    $artist_lk{$key} = $artistName;
    $title_lk{$key} = $titleName;
    $artistArray{$tmpArtist} = $artistName;

}

foreach $mykey (sort keys(%artistArray)) {
    print $ao $artistArray{$mykey} . "\n";
}

$count = 0;
print $sqlo "DELETE FROM songlist;\n\n";

foreach $mykey (sort keys(%artist_lk)) {

    $found = false;
     
    foreach (@artistDb) {
        chomp($_);
        
        #
        # Compare artist DB names to artist names from inout file, flip the found if match is found
        if ($_ eq $artist_lk{$mykey}) {
            $found = true;
            last;
        }
    } # foreach (@artistDb)
    
    if ( ! $found ) {
        $count++;
        print $artist_lk{$mykey} . " Not found...\n";
    }
    
    print $oh $artist_lk{$mykey} . "|" . $title_lk{$mykey} . "\n";
    
    $artist_lk{$mykey} =~ s/\'/\'\'/g;
    $title_lk{$mykey}  =~ s/\'/\'\'/g;
    
    print $sqlo "INSERT INTO songlist (artist, title) VALUES ('$artist_lk{$mykey}', '$title_lk{$mykey}');\n";
    
    if ( $artist_lk{$mykey} =~ /$search/ && $search ne '' ) {
        #print $oh $search . " - " . $mykey . " : " . $artist_lk{$mykey} . " " . $title_lk{$mykey} . "\n";
    }

}

print "Not found: " . $count . "\n";

close $oh;
