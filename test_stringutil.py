from src.stringutil import reverse_words, is_palindrome, count_vowels


class TestReverseWords:
    def test_basic(self):
        assert reverse_words("hello world") == "world hello"

    def test_multiple_spaces(self):
        assert reverse_words("a  b   c") == "c   b  a"

    def test_single_word(self):
        assert reverse_words("hello") == "hello"

    def test_empty_string(self):
        assert reverse_words("") == ""

    def test_leading_trailing_spaces(self):
        assert reverse_words("  hello  ") == "hello"

    def test_three_words(self):
        assert reverse_words("one two three") == "three two one"

    def test_whitespace_only(self):
        assert reverse_words("   ") == ""

    def test_tabs_and_newlines(self):
        assert reverse_words("hello\tworld\nfoo") == "foo\nworld\thello"

    def test_mixed_whitespace(self):
        assert reverse_words("a  b c   d") == "d   c b  a"


class TestIsPalindrome:
    def test_simple_palindrome(self):
        assert is_palindrome("racecar") is True

    def test_not_palindrome(self):
        assert is_palindrome("hello") is False

    def test_case_insensitive(self):
        assert is_palindrome("RaceCar") is True

    def test_ignores_punctuation(self):
        assert is_palindrome("A man, a plan, a canal: Panama") is True

    def test_ignores_spaces(self):
        assert is_palindrome("taco cat") is True

    def test_empty_string(self):
        assert is_palindrome("") is True

    def test_single_char(self):
        assert is_palindrome("a") is True

    def test_numeric_palindrome(self):
        assert is_palindrome("12321") is True

    def test_not_palindrome_with_punctuation(self):
        assert is_palindrome("hello, world!") is False


class TestCountVowels:
    def test_basic(self):
        assert count_vowels("hello") == 2

    def test_uppercase(self):
        assert count_vowels("AEIOU") == 5

    def test_mixed_case(self):
        assert count_vowels("aEiOu") == 5

    def test_no_vowels(self):
        assert count_vowels("bcdfg") == 0

    def test_empty_string(self):
        assert count_vowels("") == 0

    def test_all_vowels(self):
        assert count_vowels("aeiou") == 5

    def test_no_vowels_with_symbols(self):
        assert count_vowels("h3ll0!") == 0
