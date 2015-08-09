# Copyright © 2015 Jonathan Storm <the.jonathan.storm@gmail.com>
# This work is free. You can redistribute it and/or modify it under the
# terms of the Do What The Fuck You Want To Public License, Version 2,
# as published by Sam Hocevar. See the COPYING.WTFPL file for more details.

defprotocol Vector do
  def add(vector1, vector2)
  def subtract(vector1, vector2)
  def multiply(vector1, vector2)
  def divide(vector1, vector2)
  def inner(vector1, vector2)
  def outer(vector1, vector2)
  def bit_and(vector1, vector2)
  def bit_xor(vector1, vector2)
  def absolute(vector)
  def mod(vector, modulus)
  def dimension(vector)
  def embed(vector, dimension)
  def p_norm(vector, p)
end

defimpl Vector, for: List do
  use Bitwise

  defp vector_op(list1, list2, fun) when length(list1) == length(list2) do
    Enum.zip(list1, list2) |> Enum.map(fun)
  end
  defp vector_op(_, _, _) do
    raise ArgumentError, message: "Vectors must be of same dimension"
  end

  def add(u, v) when is_list v do
    vector_op u, v, fn {ui, vi} -> ui + vi end
  end
  def add(v, scalar) when is_number scalar do
    Enum.map v, fn vi -> vi + scalar end
  end

  def multiply(u, v) when is_list v do
    vector_op u, v, fn {ui, vi} -> ui * vi end
  end
  def multiply(v, scalar) when is_number scalar do
    Enum.map v, fn vi -> vi * scalar end
  end

  def subtract(u, v) when is_list v do
    add u, multiply(v, -1)
  end
  def subtract(v, scalar) when is_number scalar do
    Enum.map v, fn vi -> vi - scalar end
  end

  def divide(u, v) when is_list v do
    vector_op(u, v, fn {ui, vi} -> ui / vi end)
  end
  def divide(v, scalar) when is_number scalar do
    Enum.map v, fn vi -> vi / scalar end
  end

  def inner(u, v) when is_list v do
    multiply(u, v) |> Enum.sum
  end

  def outer(u, v) when is_list v do
    for ui <- u do
      multiply(v, ui)
    end
  end

  def bit_and(u, v) when is_list v do
    vector_op u, v, fn {ui, vi} -> band(ui, vi) end
  end
  def bit_and(v, scalar) when is_number scalar do
    Enum.map v, fn vi -> band(vi, scalar) end
  end

  def bit_xor(u, v) when is_list v do
    vector_op u, v, fn {ui, vi} -> bxor(ui, vi) end
  end
  def bit_xor(v, scalar) when is_number scalar do
    Enum.map v, fn vi -> bxor(vi, scalar) end
  end

  def absolute(v) do
    Enum.map v, fn vi -> abs vi end
  end

  def mod(v, modulus) do
    Enum.map v, fn vi -> Math.mod(vi, modulus) end
  end

  def dimension(v) do
    length v
  end

  def embed(v, dimension) when length(v) == dimension do
    v
  end
  def embed(v, dimension) when length(v) < dimension do
    v
    |> :binary.list_to_bin
    |> String.rjust(dimension, 0)
    |> :binary.bin_to_list
  end
  def embed(list, dimension) when length(list) > dimension do
    raise ArgumentError, message: "Cannot embed vector in space of lower dimension"
  end

  def p_norm(v, 1) do
    Enum.sum v
  end
  def p_norm(v, :inf) do
    Enum.max v
  end
  def p_norm(v, p) do
    v
    |> Enum.map(&:math.pow(&1, p))
    |> Enum.sum
    |> :math.pow(1 / p)
  end
end

defimpl Vector, for: BitString do
  use Bitwise

  defp bitstrings_to_lists(bitstrings) do
    Enum.map(bitstrings, &(:binary.bin_to_list &1))
  end

  defp vector_op(bitstring1, bitstring2, fun)
      when byte_size(bitstring1) == byte_size(bitstring2) do
    [u, v] = bitstrings_to_lists [bitstring1, bitstring2]

    Enum.zip(u, v) |> Enum.map(fun) |> :binary.list_to_bin
  end
  defp vector_op(_, _, _) do
    raise ArgumentError, message: "Vectors must be of same dimension"
  end

  def add(u, v) when is_binary v do
    vector_op(u, v, fn {ui, vi} -> Math.mod(ui + vi, 256) end)
  end
  def add(v, scalar) when is_integer scalar do
    v
    |> :binary.bin_to_list
    |> Enum.map(fn vi -> Math.mod(vi + scalar, 256) end)
    |> :binary.list_to_bin
  end

  def multiply(u, v) when is_binary v do
    vector_op(u, v, fn {ui, vi} -> Math.mod(ui * vi, 256) end)
  end
  def multiply(v, scalar) when is_integer scalar do
    v
    |> :binary.bin_to_list
    |> Enum.map(fn vi -> Math.mod(vi * scalar, 256) end)
    |> :binary.list_to_bin
  end

  def subtract(u, v) when is_binary v do
    add u, multiply(v, -1)
  end
  def subtract(v, scalar) when is_integer scalar do
    v
    |> :binary.bin_to_list
    |> Enum.map(fn vi -> Math.mod(vi - scalar, 256) end)
    |> :binary.list_to_bin
  end

  def divide(u, v) when is_binary v do
    vector_op(u, v, fn {ui, vi} -> div(ui, vi) |> Math.mod(256) end)
  end
  def divide(v, scalar) when is_integer scalar do
    v
    |> :binary.bin_to_list
    |> Enum.map(fn vi -> div(vi, scalar) |> Math.mod(256) end)
    |> :binary.list_to_bin
  end

  def inner(u, v) when is_binary v do
    u
    |> multiply(v)
    |> :binary.bin_to_list
    |> Enum.sum
  end

  def outer(bitstring1, bitstring2) when is_binary bitstring2 do
    [u, v] = bitstrings_to_lists [bitstring1, bitstring2]

    for ui <- u do
      for vj <- v, do: Math.mod(ui * vj, 256)
    end
    |> Enum.map(&:binary.list_to_bin(&1))
  end

  def bit_and(u, v) when is_binary v do
    vector_op(u, v, fn {ui, vi} -> band(ui, vi) end)
  end
  def bit_and(v, scalar) when is_integer scalar do
    v
    |> :binary.bin_to_list
    |> Enum.map(fn vi -> scalar |> Math.mod(256) |> band(vi) end)
    |> :binary.list_to_bin
  end

  def bit_xor(u, v) when is_binary v do
    vector_op(u, v, fn {ui, vi} -> bxor(ui, vi) end)
  end
  def bit_xor(u, v) when is_binary v do
    vector_op(u, v, fn {ui, vi} -> band(ui, vi) end)
  end
  def bit_xor(v, scalar) when is_integer scalar do
    v
    |> :binary.bin_to_list
    |> Enum.map(fn vi -> scalar |> Math.mod(256) |> bxor(vi) end)
    |> :binary.list_to_bin
  end

  def absolute(v) do
    v
  end

  def mod(v, modulus) do
    v
    |> :binary.bin_to_list
    |> Enum.map(fn vi -> Math.mod(vi, modulus) end)
    |> :binary.list_to_bin
  end

  def dimension(v) do
    byte_size v
  end

  def embed(v, dimension) when byte_size(v) == dimension do
    v
  end
  def embed(v, dimension) when byte_size(v) < dimension do
    String.rjust(v, dimension, 0)
  end
  def embed(v, dimension) when byte_size(v) > dimension do
    raise ArgumentError, message: "Cannot embed vector in space of lower dimension"
  end

  def p_norm(v, 1) do
    v
    |> :binary.bin_to_list
    |> Enum.sum
  end
  def p_norm(v, :inf) do
    v
    |> :binary.bin_to_list
    |> Enum.max
  end
  def p_norm(v, p) do
    v
    |> :binary.bin_to_list
    |> Enum.map(&:math.pow(&1, p))
    |> Enum.sum
    |> :math.pow(1 / p)
  end
end


defprotocol Matrix do
  def dimension(matrix)
  def multiply(matrix, matrix_or_vector)
  def transpose(matrix_or_vector)
end

defimpl Matrix, for: List do
  def dimension([row|tail]) when is_list row do
    {length([row|tail]), length(row)}
  end

  def multiply([row|tail], [row2|tail2]) when is_list(row) and is_list(row2) do
    for row <- [row|tail] do
      for col <- transpose [row2|tail2] do
        Vector.inner(row, col)
      end
    end
  end
  def multiply([row|tail], vector) when is_list(row) and is_list(vector) do
    multiply([row|tail], transpose [vector])
  end

  def transpose([row|tail]) when is_list row do
    [row|tail]
    |> List.zip
    |> Enum.map(&(Tuple.to_list &1))
  end
  def transpose(vector) do
    transpose [vector]
  end
end

