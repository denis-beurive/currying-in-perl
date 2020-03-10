# Description

Let's make some Currying with Perl.

# Example 1

`concat.pl`:

	use feature 'current_sub';
	use strict;
	use warnings FATAL => 'all';


	sub concat2 {
	    my $x = shift;
	    return (sub { my $y = shift; return "$x$y" });
	}

	print '' . concat2(10)->(20) . "\n";

	sub concat3 {
	    my $x = shift;
	    return (sub {
	        my $y = shift;
	        return (sub {
	            my $z = shift;
	            return "$x$y$z";
	        })
	    });
	}

	print '' . concat3(10)->(20)->(30) . "\n";

	sub concatAll_ {
	    my $x = shift;
	    return $x if 0 == @_;
	    return "$x" . __SUB__->(@_);
	}

	print '' . concatAll_(10, 20, 30) . "\n";


	sub concat {
	    # The function "concat" bootstraps the process.
	    # If it is called without parameters, the it returns an empty string.
	    # Otherwise, it will initiate the process that evaluates the line.
	    return '' if 0 == @_;
	    my $inCurrentResult = shift;

	    # Use a closure to capture the successive concatenations' results.
	    # Please note that we cannot use a closure to extract parameters from the line of code
	    # (since the closure's parameters are already set). We use an anonymous function for this
	    # purpose.
	    return (sub {
	        my ($inCurrentResult) = @_;
	        my $s = __SUB__;
	        return (sub {
	            # This anonymous function extracts the next value to catenate.
	            if (1 == @_) {
	                my $inValue = shift;
	                $inCurrentResult .= $inValue;
	                # Call the closure again, so the result of the catenation will not be lost.
	                return $s->($inCurrentResult);
	            }
	            return $inCurrentResult;
	        });
	    })->($inCurrentResult);
	}

	print '' . concat() . "\n";
	print concat(10)->() . "\n";
	print concat(10)->(20)->() . "\n";
	print concat(10)->(20)->(30)->() . "\n";
	print concat(10)->(20)->(30)->(40)->() . "\n";

Execution:

	$ perl concat.pl 
	1020
	102030
	102030

	10
	1020
	102030
	10203040


# Example 2

`loop1.pl`:

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

Execution:

	$ perl loop1.pl 
	1.2.3.4.5.6.7.8.9.10

# Example 3

`loop2.pl` :

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

Execution:

	$ perl loop2.pl 
	linker->(1)->(2) = '1.2'
	loop(1)->(\&incr)->(\&stop)->(\&linker) = '1.2.3.4.5.6.7.8.9.10'

