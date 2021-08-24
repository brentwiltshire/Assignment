#!/usr/bin/perl

use strict;
use warnings; 

# File name is in variable as refered to a couple of times.
my $periods = "years.txt";

# Creating years
unless(open FILE, '>',$periods) {
    # If there is an error with the file, good practice to advise
    die "\nUnable to create $periods\n";
}

# Write years to file

print FILE "2018\n";
print FILE "2019\n";
print FILE "2020\n";
print FILE "2021\n";
print FILE "\n";

# Same as exiting in bash.
close FILE;