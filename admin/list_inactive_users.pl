#!/usr/bin/perl
## Copyright (C) 2011-2013 Carnë Draug <carandraug+dev@gmail.com>
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; if not, see <http://www.gnu.org/licenses/>.

use 5.010;                      # Use Perl 5.10
use strict;                     # Enforce some good programming rules
use warnings;
use LWP::Simple qw(get);        # get web pages easily

## This perl script tries to list all the inactive users of the project,
## considering inactive users who haven't made a commit since a specific date.
##
## It first gets the list of users with access to the repository by parsing a
## HTML page from sourceforge where they are listed (parses the page correctly
## on 2011-04-19). As such, this script requires internet connection.
##
## Note: actually it places all users on a hash table to make it faster
##
## Second it runs svn for the specified repository (path must be supplied) and
## attempts to parse the logs between the HEAD of the repository and a specified
## date. The users found on these logs are removed from the list (their key is
## removed from the hash table).
##
## Finally, the list of keys is sorted and printed to STDOUT

################################################################################
## Configuration variables
################################################################################
my $repo_path   = '~/development/octave-forge/';  # path for the repository
my $date_limit  = '2012-06-10';                   # give date in format YYYY-MM-DD
my $sf_dev_list = 'http://sourceforge.net/p/octave/_members/';  # URL for sourceforge project member list

################################################################################
## No configuration beyond this point
################################################################################

## gets a hash table with usernames as keys
my %names       = get_member_list ($sf_dev_list);
## runs svn log -q -r
my @output      = `svn log -q -r HEAD:{$date_limit} $repo_path`;

my %active;
foreach my $line (@output) {
  next if '-' eq substr $line, 0, 1; # next if 1st character is a dash
  ## the following regexp reads: a "r" at the start of the line followed by at
  ## least one digit (revision number), followed by at least one whitespace,
  ## followed by a vertical bar, followed by at least one whitespace, followed by
  ## at least one word character (alphanumeric or underscore) OR dash (this is
  ## the username and is between parentheses to be extracted into $1) followed by
  ## at least one whitespace.
  $line     =~ m/^r\d+\s+\|\s+((\w|\-)+)\s+/i;
  my $name  = $1;
  ## delete key with the found username (NOT just remove the value)
  $active{$name}++;
  delete $names{$name};
}
## get list of keys, sort them alphabetically and join them with a newline for print
say "These are inactive users since $date_limit";
say join ("\n", sort keys %names);
say "These are active users since $date_limit";
for (sort keys %active) {
  say "$active{$_}\t by $_";
}

## this function takes the URL for the page with the member list and returns an
## hash table with their usernames as keys. The values for the keys is always true.
## A hash was used instead of a list to make it easier and faster to search and
## remove users
sub get_member_list {
  my $url   = $_[0];
  my $html  = get($url);
  ## use the newlines on the html page to split each line into a list
  my @lines = split (/\n/, $html);
  my %names;
  foreach my $line (@lines) {
    ## usernames in the html page can be found in the string
    ##
    ## <td><a href="/u/USERNAME_IS_HERE/">USERNAME_IS_HERE</a></td>
    ##
    ## The following regexp retrieves usernames as long as they're:
    ##    1)  \w  alphanumeric plus underscore
    ##    2)  \-  and a dash
    if ($line =~ m/<td><a href=\"\/u\/((\w|\-)+)\/\">((\w|\-)+)<\/a><\/td>/ ) {
      $names{$1} = 1; # any value is good, we only care for the key
    }
  }
  return %names;
}
