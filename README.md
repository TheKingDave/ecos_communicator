A library to easily communicate with the [ECoS](http://www.esu.eu/en/products/digital-control/ecos-50210-dcc-system/what-ecos-can-do/) command station.

## Example

The example can be run with `dart ecos_communicator_example.dart <ip address> [<id: 20000>]`.

Will only work on turnouts with 2 states (normal turnouts)

This will connect to the ECoS and present a cli interface.
Updated on the turnout state will be printed in this way:
`Switch: straight` or `Switch: curved`

* s: Will switch the turnout
* c: Will disconnect the listener on turnout updates
* m: Will reconnect the listener on turnout updates
* close: Will close the connection

## Usage

TODO

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/TheKingDave/ecos_communicator/issues
