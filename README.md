# mysql-code-128-encoder

a mysql function to encode a string to a code128 encoded string including start and stop codes and the checksum calculation.

This function is optimizing for digit sequences.

i found the function itself at https://sourceforge.net/p/openbarcodes/discussion/417149/thread/c4fd5325/

The algorithm used is very neat. Nonetheless i had to fix the start and stop codes and the switch codes to use standard complient ascii codes, and as a result the offset used for these special characters and checksum calculation.
I also made it to work in an utf-8 environment. And translated variable naming and comments to english.

## example usage

    SELECT TextTo128('Test');

or

    UPDATE table set barcode_column = TextTo128(other_column);
