x = 5;
y = 10;
z = 0;

if (x < y) {
    z = x + y;
} else {
    z = x - y;
}

do {
    x = x + 1;
    y = y - 1;
} while (x < y);

a = 100;
b = 200;

if (a > b) {
    a = a - b;
} else {
    b = b - a;
}

do {
    a = a + 5;
    b = b - 5;
} while (a < b);

result = a + b + z;