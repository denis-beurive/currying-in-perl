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

my $res = loop(1)                       # From
    ->(sub{ my $v=shift; $v+1  })       # Next
    ->(sub{ my $v=shift; $v>10 })       # End
    ->(sub{ my $v=shift; return (sub {  # Action
    my $a=shift;
    return (defined $a ? "${a}." : '') . "${v}";
})});

print "$res\n";
