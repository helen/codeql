<?php

// Test: Code injection via superglobals

// BAD: eval with user input
eval($_POST['code']);

// BAD: assert with user input
assert($_GET['assertion']);

// GOOD: no user input in eval
eval('return 42;');
