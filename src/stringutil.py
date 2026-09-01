import re


def reverse_words(s: str) -> str:
    """Reverse word order preserving original whitespace separators.

    Splits on whitespace boundaries, reverses the words, and re-joins
    them using the original separators (in the same positions).
    Leading/trailing whitespace is stripped.
    """
    tokens = re.split(r"(\s+)", s.strip())
    words = [t for t in tokens if not t.isspace()]
    seps = [t for t in tokens if t.isspace()]
    words.reverse()
    seps.reverse()
    result = []
    for i, word in enumerate(words):
        result.append(word)
        if i < len(seps):
            result.append(seps[i])
    return "".join(result)


def is_palindrome(s: str) -> bool:
    """Case-insensitive palindrome check ignoring punctuation and spaces."""
    cleaned = re.sub(r"[^a-zA-Z0-9]", "", s).lower()
    return cleaned == cleaned[::-1]


def count_vowels(s: str) -> int:
    """Count vowels (a,e,i,o,u) case-insensitive."""
    return sum(1 for ch in s.lower() if ch in "aeiou")
