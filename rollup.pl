#!/usr/bin/perl

# rollup: add up values with a common key.
#
# example:
#   key1  5
#   key1  5
#   key2  1
# 
# becomes
#   key1  10
#   key2  1
#   Total 11

my %out = ();
my %totals = ();
my $DELIMITER = "\t";

my $fh;
if ($ARGV[0]) {
    if ( -e $ARGV[0]) {
        open $fh, '<', $ARGV[0];
    } else {
        die "$ARGV[0] does not exist!\n";
    }
} else {
    open $fh, '<-';
}

while (<$fh>) {
    chomp;
    my @fields = split $DELIMITER;
    my $key = shift(@fields);
    for (my $i=0; $i<@fields; $i++) {
        $out{$key}->{$i} += $fields[$i];
        $totals{$i} += $fields[$i];
    }
}

for my $key (sort keys %out) {
    my %cols = %{ $out{$key} };
    my @idxs = sort keys %cols;
    print join($DELIMITER, $key, @cols{@idxs}) . "\n";
}

my @totals_idxs = sort keys %totals;
print join($DELIMITER, "Total", @totals{@totals_idxs}) . "\n";
