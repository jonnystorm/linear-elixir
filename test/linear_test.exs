# Copyright © 2015 Jonathan Storm <the.jonathan.storm@gmail.com>
# This work is free. You can redistribute it and/or modify it under the
# terms of the Do What The Fuck You Want To Public License, Version 2,
# as published by Sam Hocevar. See the COPYING.WTFPL file for more details.


## List ##

defmodule LinearTest do
  use ExUnit.Case, async: true

  test "adds two lists" do
    assert Vector.add([1, 1, 1], [2, 2, 2]) == [3, 3, 3]
  end
  test "adding lists of unequal length raises an error" do
    assert_raise ArgumentError, fn -> Vector.add([1, 2], [1, 2, 3]) end
  end
  test "adds a scalar to a list" do
    assert Vector.add([0, 0, 0], 1) == [1, 1, 1]
  end

  test "multiplies two lists" do
    assert Vector.multiply([1, 2, 3], [1, 2, 3]) == [1, 4, 9]
  end
  test "multiplies two lists without component wrap" do
    assert Vector.multiply([128, 128, 128], [2, 4, 6]) == [256, 512, 768]
  end
  test "multiplying lists of unequal length raises an error" do
    assert_raise ArgumentError, fn -> Vector.multiply([1, 2], [1, 2, 3]) end
  end
  test "multiplies a list by a scalar" do
    assert Vector.multiply([1, 2, 3], 3) == [3, 6, 9]
  end

  test "subtracts two lists" do
    assert Vector.subtract([1, 2, 3], [1, 2, 3]) == [0, 0, 0]
  end
  test "subtracts two lists without component wrap" do
    assert Vector.subtract([1, 2, 3], [2, 2, 3]) == [-1, 0, 0]
  end
  test "subtracting lists of unequal length raises an error" do
    assert_raise ArgumentError, fn -> Vector.subtract([1, 2], [1, 2, 3]) end
  end
  test "subtracts a scalar from a list" do
    assert Vector.subtract([0, 0, 0], 1) == [-1, -1, -1]
  end

  test "divides two lists" do
    assert Vector.divide([3, 3, 3], [1, 2, 3]) == [3, 1.5, 1]
  end
  test "dividing lists of unequal length raises an error" do
    assert_raise ArgumentError, fn -> Vector.divide([1, 2], [1, 2, 3]) end
  end
  test "divides a list by a scalar" do
    assert Vector.divide([3, 3, 3], 2) == [1.5, 1.5, 1.5]
  end

  test "dots two lists" do
    assert Vector.inner([1, 1, 1], [2, 2, 2]) == 6
  end
  test "dot-ing lists of unequal length raises an error" do
    assert_raise ArgumentError, fn -> Vector.inner([1, 2], [1, 2, 3]) end
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
  test "ANDing lists of unequal length raises an error" do
    assert_raise ArgumentError, fn -> Vector.bit_and([1, 2], [1, 2, 3]) end
  end
  test "ANDs a scalar with a list" do
    assert Vector.bit_and([3, 3, 3], 1) == [1, 1, 1]
  end

  test "XORs two lists" do
    assert Vector.bit_xor([1, 1, 1], [3, 3, 3]) == [2, 2, 2]
  end
  test "XORing lists of unequal length raises an error" do
    assert_raise ArgumentError, fn -> Vector.bit_xor([1, 2], [1, 2, 3]) end
  end
  test "XORs a scalar with a list" do
    assert Vector.bit_xor([3, 3, 3], 1) == [2, 2, 2]
  end

  test "takes the absolute value of each component in a list" do
    assert Vector.absolute([-1, -2, -3]) == [1, 2, 3]
  end

  test "takes the modulo of each component in a list" do
    assert Vector.mod([2, 3, 4], 2) == [0, 1, 0]
  end

  test "embeds list vector in space of greater dimension" do
    assert Vector.embed([1, 2, 3], 5) == [0, 0, 1, 2, 3]
  end

  test "applies the Minkowski norm for p = 1 to list" do
    vector = [1, 2, 3]

    assert Vector.p_norm(vector, 1) == 6
  end
  test "applies the Minkowski norm for p = infinity to list" do
    vector = [1, 2, 3]

    assert Vector.p_norm(vector, :inf) == 3
  end
  test "applies the Minkowski norm for p = 2 to list" do
    vector = [1, 2, 3]

    assert Vector.p_norm(vector, 2)
    == vector
      |> Enum.map(&:math.pow(&1, 2))
      |> Enum.sum
      |> :math.sqrt
  end


  ## Bitstring ##

  test "adds two bitstrings" do
    assert Vector.add(<<1, 2, 3>>, <<1, 2, 3>>) == <<2, 4, 6>>
  end
  test "adds two bitstrings, resulting in component wrap" do
    assert Vector.add(<<0, 0, 255>>, <<0, 0, 1>>) == <<0, 0, 0>>
  end
  test "adding bitstrings of unequal length raises an error" do
    assert_raise ArgumentError, fn -> Vector.add(<<1, 2>>, <<1, 2, 3>>) end
  end
  test "adds a scalar to a bitstring" do
    assert Vector.add(<<0, 0, 0>>, 1) == <<1, 1, 1>>
  end
  test "adds a scalar to a bitstring, resulting in component wrap" do
    assert Vector.add(<<255, 255, 255>>, 1) == <<0, 0, 0>>
  end
  test "adds a negative scalar to a bitstring" do
    assert Vector.add(<<0, 0, 0>>, -1) == <<255, 255, 255>>
  end

  test "multiplies two bitstrings" do
    assert Vector.multiply(<<1, 2, 3>>, <<1, 2, 3>>) == <<1, 4, 9>>
  end
  test "multiplies two bitstrings, resulting in component wrap" do
    assert Vector.multiply(<<128, 128, 128>>, <<2, 4, 6>>) == <<0, 0, 0>>
  end
  test "multiplying bitstrings of unequal length raises an error" do
    assert_raise ArgumentError, fn -> Vector.multiply(<<1, 2>>, <<1, 2, 3>>) end
  end
  test "multiplies a bitstring by a scalar" do
    assert Vector.multiply(<<1, 2, 3>>, 3) == <<3, 6, 9>>
  end
  test "multiplies a bitstring by a negative scalar" do
    assert Vector.multiply(<<1, 2, 3>>, -1) == <<255, 254, 253>>
  end

  test "subtracts two bitstrings" do
    assert Vector.subtract(<<1, 2, 3>>, <<1, 2, 3>>) == <<0, 0, 0>>
  end
  test "subtracts two bitstrings, resulting in component wrap" do
    assert Vector.subtract(<<1, 2, 3>>, <<2, 2, 3>>) == <<255, 0, 0>>
  end
  test "subtracting bitstrings of unequal length raises an error" do
    assert_raise ArgumentError, fn -> Vector.subtract(<<1, 2>>, <<1, 2, 3>>) end
  end
  test "subtracts a scalar from a binary" do
    assert Vector.subtract(<<0, 0, 0>>, 1) == <<255, 255, 255>>
  end
  test "subtracts a negative scalar from a binary" do
    assert Vector.subtract(<<0, 0, 0>>, -1) == <<1, 1, 1>>
  end

  test "divides two bitstrings" do
    assert Vector.divide(<<3, 3, 3>>, <<1, 2, 3>>) == <<3, 1, 1>>
  end
  test "dividing bitstrings of unequal length raises an error" do
    assert_raise ArgumentError, fn -> Vector.divide(<<1, 2>>, <<1, 2, 3>>) end
  end
  test "divides a bitstring by a scalar" do
    assert Vector.divide(<<0, 1, 2>>, 2) == <<0, 0, 1>>
  end
  test "divides a bitstring by a negative scalar" do
    assert Vector.divide(<<255, 255, 255>>, -1) == <<1, 1, 1>>
  end

  test "dots two bitstrings" do
    assert Vector.inner(<<1, 2, 3>>, <<1, 2, 3>>) == 14
  end
  test "dots two bitstrings, resulting in component wrap" do
    assert Vector.inner(<<128, 128, 128>>, <<2, 2, 2>>) == 0
  end
  test "dot-ing bitstrings of unequal length raises an error" do
    assert_raise ArgumentError, fn -> Vector.inner(<<1, 2>>, <<1, 2, 3>>) end
  end

  test "takes the outer product of two bitstrings" do
    assert Vector.outer(<<1, 2, 3>>, <<1, 2, 3, 4>>) ==
      [
        <<1, 2, 3,  4>>,
        <<2, 4, 6,  8>>,
        <<3, 6, 9, 12>>
      ]
  end
  test "takes the outer product of two bitstrings, resulting in component wrap" do
    assert Vector.outer(<<128, 128, 128>>, <<2, 4, 6, 8>>) ==
      [
        <<0, 0, 0, 0>>,
        <<0, 0, 0, 0>>,
        <<0, 0, 0, 0>>
      ]
  end

  test "ANDs two bitstrings" do
    assert Vector.bit_and(<<1, 1, 1>>, <<3, 3, 3>>) == <<1, 1, 1>>
  end
  test "ANDing bitstrings of unequal length raises an error" do
    assert_raise ArgumentError, fn -> Vector.bit_and(<<1, 2>>, <<1, 2, 3>>) end
  end
  test "ANDs a scalar with a bitstring" do
    assert Vector.bit_and(<<1, 1, 1>>, 3) == <<1, 1, 1>>
  end
  test "ANDs a negative scalar with a bitstring" do
    assert Vector.bit_and(<<255, 255, 255>>, -255) == <<1, 1, 1>>
  end

  test "XORs two bitstrings" do
    assert Vector.bit_xor(<<1, 1, 1>>, <<3, 3, 3>>) == <<2, 2, 2>>
  end
  test "XORing bitstrings of unequal length raises an error" do
    assert_raise ArgumentError, fn -> Vector.bit_xor(<<1, 2>>, <<1, 2, 3>>) end
  end
  test "XORs a scalar with a bitstring" do
    assert Vector.bit_xor(<<1, 1, 1>>, 3) == <<2, 2, 2>>
  end
  test "XORs a negative scalar with a bitstring" do
    assert Vector.bit_xor(<<3, 3, 3>>, -255) == <<2, 2, 2>>
  end

  test "takes the modulo of each component of a bitstring" do
    assert Vector.mod(<<2, 3, 4>>, 2) == <<0, 1, 0>>
  end

  test "embeds bitstring vector in space of greater dimension" do
    assert Vector.embed(<<1, 2, 3>>, 5) == <<0, 0, 1, 2, 3>>
  end

  test "applies the Minkowski norm for p = 1 to bitstring" do
    vector = <<1, 2, 3>>

    assert Vector.p_norm(vector, 1) == 6
  end
  test "applies the Minkowski norm for p = infinity to bitstring" do
    vector = <<1, 2, 3>>

    assert Vector.p_norm(vector, :inf) == 3
  end
  test "applies the Minkowski norm for p = 2 to bitstring" do
    vector = <<1, 2, 3>>

    assert Vector.p_norm(vector, 2)
    == vector
      |> :binary.bin_to_list
      |> Enum.map(&:math.pow(&1, 2))
      |> Enum.sum
      |> :math.sqrt
  end
end
