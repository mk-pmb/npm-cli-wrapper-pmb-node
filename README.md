
<!--#echo json="package.json" key="name" underline="=" -->
npm-cli-wrapper-pmb
===================
<!--/#echo -->

<!--#echo json="package.json" key="description" -->
Custom interface to npm&#39;s CLI.
<!--/#echo -->

Custom features:

* Set up NPM_EMAIL and NPM_TOKEN env variables, using bogus values if the
  credentials files aren't readable.





Wishlist
--------

* Simple identity management: I don't use it yet but it should be low-hanging
  fruit once I finish the `rcdir` module.
* With just `pub` as argument, do all my usual publish routine.
* More/better tests and docs.




License
-------
<!--#echo json="package.json" key=".license" -->
ISC
<!--/#echo -->
