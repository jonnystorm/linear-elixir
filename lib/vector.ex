# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

defprotocol Vector do
  def add(vector1, vector2)
  def subtract(vector1, vector2)
  def multiply(vector1, vector2)
  def divide(vector1, vector2)
  def inner(vector1, vector2)
  def outer(vector1, vector2)
  def bit_and(vector1, vector2)
  def bit_or(vector1, vector2)
  def bit_xor(vector1, vector2)
  def absolute(vector)
  def mod(vector, modulus)
  def dimension(vector)
  def embed(vector, dimension)
  def p_norm(vector, p)
end

defimpl Vector, for: List do
  use Bitwise

  defp vector_op(list1, list2, fun)
      when length(list1) == length(list2)
  do
    list1
    |> Enum.zip(list2)
    |> Enum.map(fun)
  end

  defp vector_op(_, _, _) do
    raise ArgumentError, message: "Vectors must be of same dimension"
  end

  def add(u, v) when is_list(v),
    do: vector_op(u, v, fn {ui, vi} -> ui + vi end)

  def add(v, scalar) when is_number(scalar),
    do: Enum.map(v, fn vi -> vi + scalar end)

  def multiply(u, v) when is_list(v),
    do: vector_op(u, v, fn {ui, vi} -> ui * vi end)

  def multiply(v, scalar) when is_number(scalar),
    do: Enum.map(v, fn vi -> vi * scalar end)

  def subtract(u, v) when is_list(v),
    do: add(u, multiply(v, -1))

  def subtract(v, scalar) when is_number(scalar),
    do: Enum.map(v, fn vi -> vi - scalar end)

  def divide(u, v) when is_list(v),
    do: vector_op(u, v, fn {ui, vi} -> ui / vi end)

  def divide(v, scalar) when is_number(scalar),
    do: Enum.map(v, fn vi -> vi / scalar end)

  def inner(u, v) when is_list(v),
    do: Enum.sum multiply(u, v)

  def outer(u, v) when is_list v do
    for ui <- u,
      do: multiply(v, ui)
  end

  def bit_and(u, v) when is_list(v),
    do: vector_op(u, v, fn {ui, vi} -> band(ui, vi) end)

  def bit_and(v, scalar) when is_number(scalar),
    do: Enum.map(v, fn vi -> band(vi, scalar) end)

  def bit_or(u, v) when is_list(v),
    do: vector_op(u, v, fn {ui, vi} -> bor(ui, vi) end)

  def bit_or(v, scalar) when is_number(scalar),
    do: Enum.map(v, fn vi -> bor(vi, scalar) end)

  def bit_xor(u, v) when is_list(v),
    do: vector_op(u, v, fn {ui, vi} -> bxor(ui, vi) end)

  def bit_xor(v, scalar) when is_number(scalar),
    do: Enum.map(v, fn vi -> bxor(vi, scalar) end)

  def absolute(v),
    do: Enum.map(v, fn vi -> abs vi end)

  def mod(v, modulus),
    do: Enum.map(v, fn vi -> Math.mod(vi, modulus) end)

  def dimension(v),
    do: length v

  def embed(v, dimension) when length(v) == dimension,
    do: v

  def embed(v, dimension) when length(v) < dimension do
    v
    |> :binary.list_to_bin
    |> String.pad_leading(dimension, <<0>>)
    |> :binary.bin_to_list
  end

  def embed(list, dimension) when length(list) > dimension do
    raise ArgumentError, message: "Cannot embed vector in space of lower dimension"
  end

  def p_norm(v, 1),
    do: Enum.sum v

  def p_norm(v, :inf),
    do: Enum.max v

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
    Enum.map bitstrings, &(:binary.bin_to_list &1)
  end

  defp vector_op(bitstring1, bitstring2, fun)
      when byte_size(bitstring1) == byte_size(bitstring2)
  do
    [u, v] = bitstrings_to_lists [bitstring1, bitstring2]

    u
    |> Enum.zip(v)
    |> Enum.map(fun)
    |> :binary.list_to_bin
  end

  defp vector_op(_, _, _) do
    raise ArgumentError, message: "Vectors must be of same dimension"
  end

  def add(u, v) when is_binary v do
    vector_op u, v, fn {ui, vi} ->
      Math.positive_mod(ui + vi, 256)
    end
  end

  def add(v, scalar) when is_integer scalar do
    v
    |> :binary.bin_to_list
    |> Enum.map(fn vi ->
      Math.positive_mod(vi + scalar, 256)
    end)
    |> :binary.list_to_bin
  end

  def multiply(u, v) when is_binary v do
    vector_op u, v, fn {ui, vi} ->
      Math.positive_mod(ui * vi, 256)
    end
  end

  def multiply(v, scalar) when is_integer scalar do
    v
    |> :binary.bin_to_list
    |> Enum.map(fn vi ->
      Math.positive_mod(vi * scalar, 256)
    end)
    |> :binary.list_to_bin
  end

  # 255 acts as -1 in GF(256)
  #
  def subtract(u, v) when is_binary(v),
    do: add(u, multiply(v, 255))

  def subtract(v, scalar) when is_integer scalar do
    v
    |> :binary.bin_to_list
    |> Enum.map(fn vi ->
      Math.positive_mod(vi + 256 - scalar, 256)
    end)
    |> :binary.list_to_bin
  end

  def divide(u, v) when is_binary(v) do
    vector_op u, v, fn {ui, vi} ->
      ui
      |> div(vi)
      |> Math.positive_mod(256)
    end
  end

  def divide(v, scalar) when is_integer scalar do
    v
    |> :binary.bin_to_list
    |> Enum.map(fn vi ->
      vi
      |> div(scalar)
      |> Math.positive_mod(256)
    end)
    |> :binary.list_to_bin
  end

  def inner(u, v) when is_binary v do
    u
    |> multiply(v)
    |> :binary.bin_to_list
    |> Enum.sum
  end

  def outer(bitstring1, bitstring2)
      when is_binary bitstring2
  do
    [u, v] = bitstrings_to_lists [bitstring1, bitstring2]

    for ui <- u do
      for vj <- v do
        Math.positive_mod(ui * vj, 256)
      end
    end |> Enum.map(&:binary.list_to_bin(&1))
  end

  def bit_and(u, v) when is_binary(v),
    do: vector_op(u, v, fn {ui, vi} -> band(ui, vi) end)

  def bit_and(v, scalar) when is_integer scalar do
    v
    |> :binary.bin_to_list
    |> Enum.map(fn vi ->
      scalar
      |> Math.positive_mod(256)
      |> band(vi)
    end)
    |> :binary.list_to_bin
  end

  def bit_or(u, v) when is_binary(v),
    do: vector_op(u, v, fn {ui, vi} -> bor(ui, vi) end)

  def bit_or(v, scalar) when is_integer scalar do
    v
    |> :binary.bin_to_list
    |> Enum.map(fn vi ->
      scalar
      |> Math.positive_mod(256)
      |> bor(vi)
    end)
    |> :binary.list_to_bin
  end

  def bit_xor(u, v) when is_binary(v),
    do: vector_op(u, v, fn {ui, vi} -> bxor(ui, vi) end)

  def bit_xor(v, scalar) when is_integer scalar do
    v
    |> :binary.bin_to_list
    |> Enum.map(fn vi ->
      scalar
      |> Math.positive_mod(256)
      |> bxor(vi)
    end)
    |> :binary.list_to_bin
  end

  def absolute(v), do: v

  def mod(v, modulus) do
    v
    |> :binary.bin_to_list
    |> Enum.map(fn vi ->
      Math.positive_mod(vi, modulus)
    end)
    |> :binary.list_to_bin
  end

  def dimension(v),
    do: byte_size v

  def embed(v, dimension) when byte_size(v) == dimension,
    do: v

  def embed(v, dimension) when byte_size(v) < dimension,
    do: String.pad_leading(v, dimension, <<0>>)

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
