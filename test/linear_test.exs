# Copyright © 2015 Jonathan Storm <the.jonathan.storm@gmail.com>
# This work is free. You can redistribute it and/or modify it under the
# terms of the Do What The Fuck You Want To Public License, Version 2,
# as published by Sam Hocevar. See the COPYING.WTFPL file for more details.

defmodule LinearTest do
  use ExUnit.Case, async: true

  test "adds two binaries" do
    assert Vector.add(<<1, 2, 3>>, <<1, 2, 3>>) == <<2, 4, 6>>
  end

  test "subtracts two binaries" do
    assert Vector.subtract(<<1, 2, 3>>, <<1, 2, 3>>) == <<0, 0, 0>>
  end
  test "subtracts two binaries resulting in negative components" do
    assert Vector.subtract(<<1, 2, 3>>, <<2, 2, 3>>) == <<255, 0, 0>>
  end

  test "dots two binaries" do
    assert Vector.inner(<<1, 2, 3>>, <<1, 2, 3>>) == 14
  end

  test "takes the outer product of two binaries" do
    assert Vector.outer(<<1, 2, 3>>, <<1, 2, 3, 4>>) ==
      [
        <<1, 2, 3,  4>>,
        <<2, 4, 6,  8>>,
        <<3, 6, 9, 12>>
      ]
  end

  test "ANDs two binaries" do
    assert Vector.bit_and(<<1, 1, 1>>, <<3, 3, 3>>) == <<1, 1, 1>>
  end

  test "XORs two binaries" do
    assert Vector.bit_xor(<<1, 1, 1>>, <<3, 3, 3>>) == <<2, 2, 2>>
  end

  test "takes the modulo of each component of a binary" do
    assert Vector.mod(<<2, 3, 4>>, 2) == <<0, 1, 0>>
  end

  test "embeds binary vector in space of greater dimension" do
    assert Vector.embed(<<1, 2, 3>>, 5) == <<0, 0, 1, 2, 3>>
  end

  test "adds two lists" do
    assert Vector.add([1, 1, 1], [2, 2, 2]) == [3, 3, 3]
  end

  test "subtracts two lists" do
    assert Vector.subtract([1, 2, 3], [1, 2, 3]) == [0, 0, 0]
  end
  test "subtracts two lists resulting in negative components" do
    assert Vector.subtract([1, 2, 3], [2, 2, 3]) == [-1, 0, 0]
  end
  test "lists of different length raise an error" do
    assert_raise ArgumentError, fn -> Vector.add([1, 2], [1, 2, 3]) end
  end

  test "dots two lists" do
    assert Vector.inner([1, 1, 1], [2, 2, 2]) == 6
  end

  test "takes the outer product of two lists" do
    assert Vector.outer([1, 2, 3], [1, 2, 3, 4]) ==
      [
        [1, 2, 3,  4],
        [2, 4, 6,  8],
        [3, 6, 9, 12]
      ]
  end

  test "ANDs two lists" do
    assert Vector.bit_and([1, 1, 1], [3, 3, 3]) == [1, 1, 1]
  end

  test "XORs two lists" do
    assert Vector.bit_xor([1, 1, 1], [3, 3, 3]) == [2, 2, 2]
  end

  test "takes the modulo of each component of a list" do
    assert Vector.mod([2, 3, 4], 2) == [0, 1, 0]
  end

  test "embeds list vector in space of greater dimension" do
    assert Vector.embed([1, 2, 3], 5) == [0, 0, 1, 2, 3]
  end
end
