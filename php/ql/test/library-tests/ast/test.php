<?php

// Test file for AST node extraction

namespace App\Test;

use App\Models\User;

class TestClass extends BaseClass implements TestInterface {
    private string $name;
    protected int $count = 0;

    public function __construct(string $name) {
        $this->name = $name;
    }

    public function getName(): string {
        return $this->name;
    }

    public function process(array $items, int $limit = 10): void {
        foreach ($items as $key => $value) {
            if ($key >= $limit) {
                break;
            }
            echo $value . "\n";
        }
    }

    public static function create(string $name): static {
        return new static($name);
    }
}

function standalone(int $x, int $y): int {
    return $x + $y;
}

$fn = fn($x) => $x * 2;

$closure = function ($x) use ($fn) {
    return $fn($x);
};

$result = match($x) {
    1 => 'one',
    2 => 'two',
    default => 'other',
};

try {
    $obj = new TestClass("test");
    $obj->process([1, 2, 3]);
} catch (\Exception $e) {
    echo $e->getMessage();
} finally {
    echo "done";
}
