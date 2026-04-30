<?php
// Test control flow graph generation

function testIf($x) {
    if ($x > 0) {
        return "positive";
    } else {
        return "negative";
    }
}

function testLoop($n) {
    $sum = 0;
    for ($i = 0; $i < $n; $i++) {
        $sum += $i;
    }
    return $sum;
}

function testTryCatch() {
    try {
        $result = riskyOperation();
    } catch (Exception $e) {
        $result = "error";
    }
    return $result;
}

function testSwitch($x) {
    switch ($x) {
        case 1:
            return "one";
        case 2:
            return "two";
        default:
            return "other";
    }
}

function testWhile($x) {
    while ($x > 0) {
        $x--;
        if ($x === 5) {
            break;
        }
        if ($x === 3) {
            continue;
        }
    }
    return $x;
}
