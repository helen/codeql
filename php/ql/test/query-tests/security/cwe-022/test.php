<?php

// Test: Path injection via superglobals

// BAD: user-controlled file path
$file = $_GET['file'];
$contents = file_get_contents($file);

// BAD: user-controlled include
include($_GET['page']);

// GOOD: restricted path
$allowed = ['about', 'contact', 'help'];
$page = $_GET['page'];
if (in_array($page, $allowed)) {
    include("pages/" . $page . ".php");
}
