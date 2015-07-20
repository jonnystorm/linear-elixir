# Copyright © 2015 Jonathan Storm <the.jonathan.storm@gmail.com>
# This work is free. You can redistribute it and/or modify it under the
# terms of the Do What The Fuck You Want To Public License, Version 2,
# as published by Sam Hocevar. See the COPYING.WTFPL file for more details.

defprotocol Vector do
  def add(vector1, vector2)
  def subtract(vector1, vector2)
  def inner(vector1, vector2)
  def outer(vector1, vector2)
  def bit_and(vector1, vector2)
  def bit_xor(vector1, vector2)
  def mod(vector, modulus)
  def dimension(vector)
  def embed(vector, dimension)
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

  def add(u, v) do
    vector_op(u, v, fn {ui, vi} -> ui + vi end)
  end

  def subtract(u, v) do
    vector_op(u, v, fn {ui, vi} -> Math.mod(ui - vi, 256) end)
  end

  def inner(u, v) do
    vector_op(u, v, fn {ui, vi} -> ui * vi end)
    |> :binary.bin_to_list
    |> Enum.sum
  end

  def outer(bitstring1, bitstring2) do
    [u, v] = bitstrings_to_lists [bitstring1, bitstring2]

    for ui <- u do
      for vj <- v, do: ui * vj
    end
    |> Enum.map(&(:binary.list_to_bin &1))
  end
  
  def bit_and(u, v) do
    vector_op(u, v, fn {ui, vi} -> band(ui, vi) end)
  end

  def bit_xor(u, v) do
    vector_op(u, v, fn {ui, vi} -> bxor(ui, vi) end)
  end

  def mod(bitstring, modulus) do
    bitstring
    |> :binary.bin_to_list
    |> Enum.map(fn vi -> Math.mod(vi, modulus) end)
    |> :binary.list_to_bin
  end

  def dimension(bitstring) do
    byte_size bitstring
  end

  def embed(bitstring, dimension) when byte_size(bitstring) == dimension do
    bitstring
  end
  def embed(bitstring, dimension) when byte_size(bitstring) < dimension do
    String.rjust(bitstring, dimension, 0)
  end
  def embed(bitstring, dimension) when byte_size(bitstring) > dimension do
    raise ArgumentError, message: "Cannot vector embed in space of lower dimension"
  end
end

defimpl Vector, for: List do
  use Bitwise

  defp vector_op(list1, list2, fun) when length(list1) == length(list2) do
    Enum.zip(list1, list2) |> Enum.map(fun)
  end
  defp vector_op(_, _, _) do
    raise ArgumentError, message: "Vectors must be of same dimension"
  end

  def add(u, v) do
    vector_op(u, v, fn {ui, vi} -> ui + vi end)
  end

  def subtract(u, v) do
    vector_op(u, v, fn {ui, vi} -> ui - vi end)
  end

  def inner(u, v) do
    vector_op(u, v, fn {ui, vi} -> ui * vi end) |> Enum.sum
  end

  def outer(list1, list2) do
    [u, v] = [list1, list2]

    for ui <- u do
      for vj <- v, do: ui * vj
    end
  end

  def bit_and(u, v) do
    vector_op(u, v, fn {ui, vi} -> band(ui, vi) end)
  end

  def bit_xor(u, v) do
    vector_op(u, v, fn {ui, vi} -> bxor(ui, vi) end)
  end

  def mod(list, modulus) do
    Enum.map(list, fn vi -> Math.mod(vi, modulus) end)
  end

  def embed(list, dimension) when length(list) == dimension do
    list
  end
  def embed(list, dimension) when length(list) < dimension do
    list
    |> :binary.list_to_bin
    |> String.rjust(dimension, 0)
    |> :binary.bin_to_list
  end
  def embed(list, dimension) when length(list) > dimension do
    raise ArgumentError, message: "Cannot vector embed in space of lower dimension"
  end

  def dimension(list) do
    length list
  end
end

defprotocol Matrix do
  def dimension(matrix)
  def multiply(matrix, matrix_or_vector)
  def transpose(matrix_or_vector)
end

defimpl Matrix, for: List do
  def dimension([row|tail]) when is_list(row) do
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

  def transpose([row|tail]) when is_list(row) do
    [row|tail]
    |> List.zip
    |> Enum.map(&(Tuple.to_list &1))
  end
  def transpose(vector) do
    transpose [vector]
  end
end

