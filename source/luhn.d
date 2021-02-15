module luhn;

import std.functional;
import std.stdio: write, writeln, writef, writefln;
import std.algorithm.comparison : equal;
import std.algorithm.iteration : map, filter;
import std.array : split;
import std.conv : to;
import std.range;
import std.algorithm;

bool valid(string numbers){
  return
     pipe!(
           map!(to!int),
           filter!(i => !(i >= 48 && i <= 57) && i != 32),
           a => a.array,
           a => a.length
           )
     (numbers) == 0
     &&
     pipe!(
           map!(to!int),
           filter!(i => i >= 48 && i <= 57),
           a => a.array,
           a => a.length
           )
     (numbers)
     > 1
     &&
    pipe!(
          map!(to!int),
          map!((int i) => (i - 48)),
          filter!((int i) => i >= 0 && i <= 9),
          a => a.array.reverse,
          ia => zip(ia, 99.iota),
          map!(v => v[1] % 2 != 0 ? v[0] * 2 : v[0]),
          map!(i => i > 9 ? i - 9 : i),
          reduce!((a, b) => a+b),
          i => i % 10,
          i => i == 0
          )
      (numbers);
}

unittest
{
    immutable int allTestsEnabled = 1;
    immutable int unitTestFlag = 1;

    // Single digit strings can not be valid
    static if(unitTestFlag)
    assert(!valid("1"));

    static if (unitTestFlag && allTestsEnabled)
    {
        // A single zero is invalid
        assert(!valid("0"));

        // A simple valid SIN that remains valid if reversed
        assert(valid("059"));

        // A simple valid SIN that becomes invalid if reversed
        assert(valid("59"));

        // A valid Canadian SIN
        assert(valid("055 444 285"));

        // Invalid Canadian SIN
        assert(!valid("055 444 286"));

        // Invalid credit card
        assert(!valid("8273 1232 7352 0569"));

        // Valid number with an even number of digits
        assert(valid("095 245 88"));

        // Valid number with an odd number of spaces
        assert(valid("234 567 891 234"));

        // Valid strings with a non-digit added at the end become invalid
        assert(!valid("059a"));

        // Valid strings with punctuation included become invalid
        assert(!valid("055-444-285"));

        // Valid strings with symbols included become invalid
        assert(!valid("055# 444$ 285"));

        // Single zero with space is invalid
        assert(!valid(" 0"));

        // More than a single zero is valid
        assert(valid("0000 0"));

        // Input digit 9 is correctly converted to output digit 9
        assert(valid("091"));

        /*
        Convert non-digits to their ascii values and then offset them by 48 sometimes accidentally declare an invalid string to be valid. 
        This test is designed to avoid that solution.
        */

        // Using ascii value for non-doubled non-digit isn't allowed
        assert(!valid("055b 444 285"));

        // Using ascii value for doubled non-digit isn't allowed
        assert(!valid(":9"));
    }

}
