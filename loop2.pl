#!/usr/bin/perl
use feature 'current_sub';
use strict;
use warnings FATAL => 'all';



sub loop {
    my $from = shift;
    return (sub {
        my $next = shift;
        return (sub {
            my $end = shift;
            return (sub {
                my $action = shift;
                my $accumulator;

                return (sub {
                    my $from = shift;
                    my $s = __SUB__;
                    return (sub {
                        my $accumulator = shift;
                        return $accumulator if ($end->($from));
                        my $r = $action->($from)->($accumulator);
                        $s->($next->($from))->($r);
                    });
                })->($from)->($accumulator);
            });
        });
    });
}

# Test whether the loop should end or not.
# @param $inValue The current loop's counter.
# @return This function returns the value true if the loop must stop.
#         Otherwise, it returns the value false.

sub stop {
    my $inValue = shift;
    $inValue > 10;
}

# Return the next value for the loop's counter.
# @param $inValue The current loop's counter.
# @return This function returns the next value for the loop's counter.

sub incr {
    my $inValue = shift;
    $inValue + 1;
}

# "Link" two values. For example:
#
#     linker(2)->(1)     => 1.2
#     linker('b')->('a') => a.b

sub linker {
    my $value = shift;
    (sub {
        my $accumulator = shift;
        return (defined $accumulator ? "${accumulator}." : '') . "${value}";
    })
}

printf "linker->(1)->(2) = '%s'\n", linker(2)->(1);
printf "loop(1)->(\\&incr)->(\\&stop)->(\\&linker) = '%s'\n", loop(1)->(\&incr)->(\&stop)->(\&linker);

