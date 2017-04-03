linear-elixir
========

[![Build Status](https://travis-ci.org/jonnystorm/linear-elixir.svg?branch=master)](https://travis-ci.org/jonnystorm/linear-elixir)

A *tiny* collection of vector/matrix operations for Elixir.

### To use:

Add this repository as a dependency to your mix.exs and run ``mix do deps.get deps.compile``.

#### Vector operations

The ``Vector`` protocol contains operations for addition (subtraction), bitwise
and/xor, and inner/outer products. There are two implementations: one for
``BitString`` and one for ``List``.

```
iex> Vector.add [1, 2, 3, 4], [5, 6, 7, 8]
[6, 8, 10, 12]
iex> Vector.add <<1, 2, 3, 4>>, <<5, 6, 7, 8>>
<<6, 8, 10, 12>>

iex> Vector.inner [1, 2, 3, 4], [5, 6, 7, 8]
70
iex> Vector.inner <<1, 2, 3, 4>>, <<5, 6, 7, 8>>
70

iex> Vector.outer [1, 2, 3, 4], [5, 6, 7, 8]
[[5, 6, 7, 8], [10, 12, 14, 16], [15, 18, 21, 24], [20, 24, 28, 32]]
iex> Vector.outer <<1, 2, 3, 4>>, <<5, 6, 7, 8>>
[<<5, 6, 7, 8>>, <<10, 12, 14, 16>>, <<15, 18, 21, 24>>, <<20, 24, 28, 32>>]

iex> Vector.bit_xor [0, 1, 1, 0], [1, 1, 1, 1]
[1, 0, 0, 1]
iex> Vector.bit_xor <<0, 1, 1, 0>>, <<1, 1, 1, 1>>
<<1, 0, 0, 1>>

iex> Vector.bit_xor [1, 2, 4], [1, 3, 7]
[0, 1, 3]
iex(10)> Vector.bit_xor <<1, 2, 4>>, <<1, 3, 7>>
<<0, 1, 3>>
```

#### Matrix operations

Matrix operations are sorely lacking, but right-multiplication and transpose
work fine. For now, the ``Matrix`` protocol has only a ``List`` implementation.

```
iex> Vector.outer([1, 2, 3], [4, 5, 6, 7]) |> Matrix.dimension
{3, 4}

iex> Matrix.multiply [[1, 0], [-1, 1]], [[1, 2], [3, 4]]
[[1, 2], [2, 2]]
iex> Matrix.transpose [[1, 2], [2, 2]]
[[1, 2], [2, 2]]

iex> Matrix.multiply [[1, 0], [-1, 1]], [3, 5]
[[3], [2]]
iex> Matrix.transpose [[3], [2]]
[[3, 2]]
```
