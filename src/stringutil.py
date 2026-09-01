import re


def reverse_words(s: str) -> str:
    return " ".join(s.split()[::-1])


def is_palindrome(s: str) -> bool:
    cleaned = re.sub(r"[^a-zA-Z0-9]", "", s).lower()
    return cleaned == cleaned[::-1]


def count_vowels(s: str) -> int:
    return sum(1 for ch in s.lower() if ch in "aeiou")
