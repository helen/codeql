<?php

// Test: Reflected XSS via superglobals

// BAD: echoing user input directly
echo $_GET['name'];

// BAD: using print
print($_POST['message']);

// GOOD: escaped output
echo htmlspecialchars($_GET['name']);
