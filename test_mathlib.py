import pytest
from src.mathlib import gcd, fibonacci, is_prime


class TestGCD:
    def test_basic(self):
        assert gcd(12, 8) == 4
        assert gcd(100, 75) == 25

    def test_coprime(self):
        assert gcd(7, 13) == 1

    def test_zero(self):
        assert gcd(0, 5) == 5
        assert gcd(5, 0) == 5
        assert gcd(0, 0) == 0

    def test_negative(self):
        assert gcd(-12, 8) == 4
        assert gcd(12, -8) == 4


class TestFibonacci:
    def test_base(self):
        assert fibonacci(0) == 0
        assert fibonacci(1) == 1

    def test_known_values(self):
        assert fibonacci(5) == 5
        assert fibonacci(10) == 55
        assert fibonacci(20) == 6765

    def test_negative_raises(self):
        with pytest.raises(ValueError):
            fibonacci(-1)


class TestIsPrime:
    def test_small(self):
        assert is_prime(2) is True
        assert is_prime(3) is True
        assert is_prime(4) is False

    def test_edge_cases(self):
        assert is_prime(0) is False
        assert is_prime(1) is False
        assert is_prime(-5) is False

    def test_larger(self):
        assert is_prime(97) is True
        assert is_prime(100) is False
        assert is_prime(7919) is True
