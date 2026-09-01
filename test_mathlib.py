from src.mathlib import gcd, fibonacci, is_prime


class TestGcd:
    def test_basic(self):
        assert gcd(12, 8) == 4

    def test_coprime(self):
        assert gcd(7, 13) == 1

    def test_zero(self):
        assert gcd(0, 5) == 5
        assert gcd(5, 0) == 5

    def test_equal(self):
        assert gcd(6, 6) == 6


class TestFibonacci:
    def test_base(self):
        assert fibonacci(0) == 0
        assert fibonacci(1) == 1

    def test_positive(self):
        assert fibonacci(5) == 5
        assert fibonacci(10) == 55

    def test_negative_raises(self):
        import pytest
        with pytest.raises(ValueError):
            fibonacci(-1)


class TestIsPrime:
    def test_small(self):
        assert not is_prime(0)
        assert not is_prime(1)
        assert is_prime(2)
        assert is_prime(3)

    def test_composite(self):
        assert not is_prime(4)
        assert not is_prime(100)

    def test_larger_primes(self):
        assert is_prime(97)
        assert is_prime(7919)
