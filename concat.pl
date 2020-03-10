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
