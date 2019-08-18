#!/bin/perl
use strict;



my $dbg_template_file = "uiecswitchx.dbg.prg";
my $dbg_outfile = "dbgfile.cvt";
my $ld65_lbl_file = "geoLink.lbl";    # --Ln uIecSwitch128.lbl
my $ld65_dbg_file = "geoLink.dbg"; # -dbgfile uIecSwitch128.dbg

my $symbol_file_type = 0;   # 0 = ld65_lbl_file, 1 = ld65_dbg_file


my $template_bytes = 762;		# use with ld65_dbg_file
#my $template_bytes = 0xc0a;	# use with ld65_lbl_file

open my $fh, '<:raw', "$dbg_template_file";

# Skip the first two bytes
# read $fh, my $bytes, 2;

# Read the rest
my $bytes_read = read $fh, my $bytes, $template_bytes;
die 'Got $bytes_read but expected $template_bytes' unless $bytes_read == $template_bytes;

my ($vlir_sector_count) = unpack ('H*', substr($bytes, 0x1fc, 1));
my ($vlir_last_sector_index) = unpack ('H*', substr($bytes, 0x1fd, 1));

print "$vlir_sector_count\n";
print "$vlir_last_sector_index\n";

my %labels;
my %addresses;

if ($symbol_file_type == 0) {
	open (LBLFILE, "<$ld65_lbl_file") or die "Could not open file $ld65_lbl_file";

	while (my $line = <LBLFILE>) {

		  $line =~ /al \w\w(\w\w\w\w) \.(.*)/;

		  #my $address_hi = $1;
		  #my $address_lo = $2;
		  my $address = $1;
		  my $label = $2;

		  # Skip __ lines
		  if ($label =~ /__/) {
			next;
		  }
		 
		  # Remove all underscores
		  #$label =~ s/_//g;

		  #if ($label =~ /@.*/) {
		  #  print "  @ label.  Skipping...\n";
		  #  next;
		  #}

		  #if ($labels{$label}) {
		  #  print "  Duplicate label.  Skipping...\n";
		  #  next;
		  #}
		  #if ($addresses{$address}) {
		  #  print "  Duplicate address.  Skipping...\n";
		  #  next;
		  #}

		  if ($address eq "" | $address eq "" | $label eq "") {
			next;
		  }

		  $labels{$label} = 1;
		  $addresses{$address} = $label;

		  #print $line;
		  print "$address $label\n";
		}
}
else {
	open (LBLFILE, "<$ld65_dbg_file") or die "Could not open file $ld65_dbg_file	";

	while (my $line = <LBLFILE>) {
	
		# sym	id=0,name="menuWidthB",addrsize=absolute,size=2,scope=0,def=866,val=0x11BF,seg=6,type=lab
		# sym	id=899,name="r10L",addrsize=zeropage,scope=0,def=945,val=0x16,type=equ
		#sym	id=921,name="r3",addrsize=zeropage,scope=0,def=1630,ref=1932+1932+1578+1578+1578+1594+1594+1959+1959+625+625+1857+1857+51+51+1743+1743+1692+1692+923+923+180+180+445+445+2010+2010+1052+1052+709+709+1780+1780,val=0x8,type=equ
		# sym	id=471,name="BACKSPACE",addrsize=zeropage,scope=0,def=372,ref=1271,val=0x8,type=equ
		if (! ($line =~ /sym\s+id=\d+,name="(\w+)".*?val=0x(\w+),/)) {
			next;
		}

		#print $line;
		$line =~ /sym id=(\d+),name="(\w+)"/;
		  
		#print "$1 $2\n";
		#next;

		my $address = $2;
		my $label = $1;
		
		print "! $address $label\n";

		if ($address eq "" | $label eq "") {
			next;
		}
		
		$address = sprintf("%04d", $address);

		$labels{$label} = 1;
		$addresses{$address} = $label;

		  #print $line;
		print "!! $address $label\n";
	}

}

print "==================================================\n";

foreach my $address (sort keys %addresses) {

  my $label = $addresses{$address};
  
  # Pad label to 8
  $label = substr($label, 0, 8);  
  $label = sprintf "%-8s", $label;

  $bytes .= "$label" . pack 'H*', $address;

  print "$address $label\n";
  
  #print OUT "$label" . pack 'H*', $address_hi . pack 'H*', $address_lo;

}

my @string_as_array = split( '', $bytes );

my $length = length($bytes) - 1;

# Location 0x1fc contains the number of 254 byte sectors
# Location 0x1fd contains the number of bytes in the last sector
# This is all starting from 0x1fc
$vlir_sector_count = ($length - 0x1fc) / 254;
$vlir_last_sector_index = ($length - 0x1fc) % 254;

#$string_as_array[0x1fc] = $temp;
$string_as_array[0x1fc] = pack 'c*', $vlir_sector_count;
$string_as_array[0x1fd] = pack 'c*', $vlir_last_sector_index;

$bytes = join( '', @string_as_array );

# Create new file with header
open OUT, ">$dbg_outfile";
binmode OUT;
print OUT $bytes;


close OUT;
close LBLFILE;


