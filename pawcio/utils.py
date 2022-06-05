def compare_word_sets(a, b):
    return set([tuple(x) for x in a]) == set([tuple(x) for x in b])


def contains_words(result, words):
    for w in words:
        if w not in result:
            return False
    return True
