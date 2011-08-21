#! /usr/bin/perl
################################################################################
## taskwarrior - a command line task list manager.
##
## Copyright 2006 - 2011, Paul Beckingham, Federico Hernandez.
## All rights reserved.
##
## This program is free software; you can redistribute it and/or modify it under
## the terms of the GNU General Public License as published by the Free Software
## Foundation; either version 2 of the License, or (at your option) any later
## version.
##
## This program is distributed in the hope that it will be useful, but WITHOUT
## ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
## FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
## details.
##
## You should have received a copy of the GNU General Public License along with
## this program; if not, write to the
##
##     Free Software Foundation, Inc.,
##     51 Franklin Street, Fifth Floor,
##     Boston, MA
##     02110-1301
##     USA
##
################################################################################

use strict;
use warnings;
use Test::More tests => 23;

# Create the rc file.
if (open my $fh, '>', 'op.rc')
{
  print $fh "data.location=.\n",
            "confirmation=no\n";
  close $fh;
  ok (-r 'op.rc', 'Created op.rc');
}

# Setup: Add a task
qx{../src/task rc:op.rc add one   due:yesterday priority:H};
qx{../src/task rc:op.rc add two   due:tomorrow  priority:M};
qx{../src/task rc:op.rc add three               priority:L};
qx{../src/task rc:op.rc add four                          };

# Test the '>' operator.
my $output = qx{../src/task rc:op.rc ls due.after:today};
unlike ($output, qr/one/,   'ls due.after:today --> !one');
like   ($output, qr/two/,   'ls due.after:today --> two');
unlike ($output, qr/three/, 'ls due.after:today --> !three');
unlike ($output, qr/four/,  'ls due.after:today --> !four');

my $output = qx{../src/task rc:op.rc ls 'due > today'};
unlike ($output, qr/one/,   'ls due > today --> !one');
like   ($output, qr/two/,   'ls due > today --> two');
unlike ($output, qr/three/, 'ls due > today --> !three');
unlike ($output, qr/four/,  'ls due > today --> !four');

my $output = qx{../src/task rc:op.rc ls priority.above:L};
like   ($output, qr/one/,   'ls priority.above:L --> one');
like   ($output, qr/two/,   'ls priority.above:L --> two');
unlike ($output, qr/three/, 'ls priority.above:L --> !three');
unlike ($output, qr/four/,  'ls priority.above:L --> !four');

my $output = qx{../src/task rc:op.rc ls 'priority > L'};
like   ($output, qr/one/,   'ls priority > L --> one');
like   ($output, qr/two/,   'ls priority > L --> two');
unlike ($output, qr/three/, 'ls priority > L --> !three');
unlike ($output, qr/four/,  'ls priority > L --> !four');

# Cleanup.
unlink 'pending.data';
ok (!-r 'pending.data', 'Removed pending.data');

unlink 'completed.data';
ok (!-r 'completed.data', 'Removed completed.data');

unlink 'undo.data';
ok (!-r 'undo.data', 'Removed undo.data');

unlink 'backlog.data';
ok (!-r 'backlog.data', 'Removed backlog.data');

unlink 'synch.key';
ok (!-r 'synch.key', 'Removed synch.key');

unlink 'op.rc';
ok (!-r 'op.rc', 'Removed op.rc');

exit 0;
