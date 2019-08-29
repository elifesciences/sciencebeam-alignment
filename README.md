# ScienceBeam Alignment

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

ScienceBeam Alignment provides generic low-level sequence alignment utility functions, similar to Python's [SequenceMatcher](https://docs.python.org/3/library/difflib.html).

This project is currently mainly used for training data generation, related to the [ScienceBeam project](https://github.com/elifesciences/sciencebeam). Although this project itself has no ScienceBeam dependency and can be considered a standalone sequence alignment library. It is however more targeted at document size sequences rather than massive gene sequences.

## Pre-requisites

- Python 2 or 3

## API

### SequenceMatcher

The mostly drop-in replacement of Python's [SequenceMatcher](https://docs.python.org/3/library/difflib.html)
is provided by [fuzzywuzzy](https://github.com/seatgeek/fuzzywuzzy)'s [StringMatcher](https://github.com/seatgeek/fuzzywuzzy/blob/master/fuzzywuzzy/StringMatcher.py).

In that respect, `sciencebeam-alignment` merely provides a wrapper with fallback.

### WordSequenceMatcher

A wrapper around the aforementioned `SequenceMatcher`, but matching on word level tokens only.

It currently only implements `get_matching_blocks`.

The main advantage is that it is much faster for long texts, because it won't have to match individual characters. It isn't recommended for short texts, where character level alignment is probably more desirable.

example match results:

```python
>>> from sciencebeam_alignment.word_sequence_matcher import (
...     WordSequenceMatcher
... )
>>> WordSequenceMatcher(a='word1', b='word2').get_matching_blocks()
[]
>>> WordSequenceMatcher(a='a word1 b', b='x word1 y').get_matching_blocks()
[(2, 2, 5)]
```

### GlobalSequenceMatcher and LocalSequenceMatcher

The [GlobalSequenceMatcher and LocalSequenceMatcher](https://github.com/elifesciences/sciencebeam-alignment/blob/develop/sciencebeam_alignment/align.py) implements the [Needleman-Wunsch](https://en.wikipedia.org/wiki/Needleman%E2%80%93Wunsch_algorithm) [global alignment](https://en.wikipedia.org/wiki/Sequence_alignment#Global_and_local_alignments) as well as the [Smith-Waterman](https://en.wikipedia.org/wiki/Smith%E2%80%93Waterman_algorithm) local alignment algorithms. The implementation is somewhat inspired by [python-alignment](https://github.com/eseraygun/python-alignment).

It does implement `get_matching_blocks` to match Python's [SequenceMatcher](https://docs.python.org/3/library/difflib.html).

By passing in a scoring object, the results can be influenced (e.g. gaps can be penalized more than mismatches).

It does also provide an optimized implementation using [Cython](https://cython.org/). The level of optimization depends on the type of passed in sequences and scoring. The fastest being with integer sequences and simple scoring. Especially with longer sequences, the potential speed ups can be significant.

```python
>>> from sciencebeam_alignment.align import LocalSequenceMatcher, SimpleScoring
>>> DEFAULT_SCORING = SimpleScoring(match_score=3, mismatch_score=-1, gap_score=-2)
>>> LocalSequenceMatcher(a='a word1 b', b='x word2 y', scoring=DEFAULT_SCORING).get_matching_blocks()
[(1, 1, 5), (7, 7, 1), (9, 9, 0)]
```

In addition, the `get_multiple_matching_blocks` can be used to retrieve multiple matching blocks with the same score:

```python
>>> from sciencebeam_alignment.align import GlobalSequenceMatcher, SimpleScoring
>>> DEFAULT_SCORING = SimpleScoring(match_score=3, mismatch_score=-1, gap_score=-2)
>>> matcher = GlobalSequenceMatcher(a='xyzabc', b='abcxyz', scoring=DEFAULT_SCORING)
>>> list(matcher.get_multiple_matching_blocks(limit=2))
[[(3, 0, 3)], [(0, 3, 3)]]
```

`get_multiple_matching_blocks` returns a generator. The number of variations can be limited using the `limit` argument or by simply stopping early.

The `GlobalSequenceMatcher` can also be used to calculate the [Levenshtein distance](https://en.wikipedia.org/wiki/Levenshtein_distance) (or _edit distance_). An example is provided in `sciencebeam_alignment.levenshtein`:

```python
>>> from sciencebeam_alignment.levenshtein import get_levenshtein_distance
>>> get_levenshtein_distance('kitten', 'sitting')
3
>>> from sciencebeam_alignment.levenshtein import get_levenshtein_ratio
>>> get_levenshtein_ratio('kitten', 'sitting')
0.5714285714285714
```

Calculating the levenshtein distance is mainly provided as an example. You might want to consider using [python-Levenshtein](https://github.com/ztane/python-Levenshtein).

To check whether the fast implementation is enabled:

```python
>>> from sciencebeam_alignment.align import native_enabled
>>> native_enabled
True
```

## Development

Development can be done either using Docker (default) or a virtual environment.

All commands are available via `make`.

### Development using Docker

Build and run tests:

```bash
make build test
```

Or intended for CI:

```bash
make ci-build-and-test
```

### Development using a virtual environment

`make` targets with the `dev-` prefix are intended for the use with the virtual environment.

This requires that you already have Python installed.

#### Setup (virtual environment)

```bash
make dev-venv
```

To update the dependencies:

```bash
make dev-install
```

#### Cython (virtual environment)

Compile code using Cython:

```bash
make dev-cython-clean dev-cython-compile
```

#### Tests (virtual environment)

```base
make dev-test
```

Or:

```base
make dev-watch
```
