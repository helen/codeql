<?php

// Test file for dataflow analysis

function process_input() {
    $user_input = $_GET['name'];
    $processed = strtolower($user_input);
    return $processed;
}

function db_query($conn, $input) {
    $query = "SELECT * FROM users WHERE name = '" . $input . "'";
    $conn->query($query);
}
