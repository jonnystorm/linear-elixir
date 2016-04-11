# Copyright © 2015 Jonathan Storm <the.jonathan.storm@gmail.com>
# This work is free. You can redistribute it and/or modify it under the
# terms of the Do What The Fuck You Want To Public License, Version 2,
# as published by Sam Hocevar. See the COPYING.WTFPL file for more details.

defmodule Linear do
  ## Operations ##

  @spec dimension([[number]]) :: {pos_integer, pos_integer}
  def dimension(object = [[_|_] | _]) when is_list object do
    {length(object), length(hd object)}
  end

  defp combine_lists(list_a, list_b, fun) do
    list_a
      |> Enum.zip(list_b)
      |> Enum.map(fn {a_i, b_i} -> fun.(a_i, b_i) end)
  end

  @spec add([[number]], [[number]]) :: [[number]]
  def add(u = [[_|_] | _], v = [[_|_] | _])
      when length(u) == length(v)
      and length(hd u) == length(hd v) do

    combine_lists u, v, fn (u_i, v_i) ->
      combine_lists u_i, v_i, &(&1 + &2)
    end
  end

  @spec subtract([[number]], [[number]]) :: [[number]]
  def subtract(u = [[_|_] | _], v = [[_|_] | _])
      when length(u) == length(v)
      and length(hd u) == length(hd v) do

    v
      |> multiply(-1)
      |> add(u)
  end

  defp weighted_sum(list_a, list_b) do
    Enum.sum combine_lists(list_a, list_b, &(&1 * &2))
  end

  @spec matrix_product([[number]], [[number]]) :: [[number]]
  def matrix_product(matrix1, matrix2)
      when length(hd matrix1) == length(matrix2) do

    for row <- matrix1 do
      for column <- transpose matrix2 do
        weighted_sum row, column
      end
    end
  end

  @spec dot_product([[number]], [[number]]) :: number
  def dot_product(row = [[_ | _]], column = [[_] | _]) do
    matrix_product row, column
  end

  @spec tensor_product([[number]], [[number]]) :: [[number]]
  defp _tensor_product(u, v) when is_number(u) and is_number(v) do
    u * v
  end
  defp _tensor_product(u, v) do
    for u_i <- u, v_j <- v do
      _tensor_product u_i, v_j
    end
  end

  @spec tensor_product([[number]], [[number]]) :: [[number]]
  def tensor_product(tensor1 = [[_|_] | _], tensor2 = [[_|_] | _]) do
    _tensor_product tensor1, tensor2
  end

  @spec multiply(number, number) :: number
  @spec multiply(number, [[number]]) :: [[number]]
  @spec multiply([[number]], number) :: [[number]]
  @spec multiply([[number]], [[number]]) :: number | [[number]]
  def multiply(scalar1, scalar2)
      when is_number(scalar1) and is_number(scalar2) do

    multiply [[scalar1]], [[scalar2]]
  end
  def multiply(scalar, rows = [[_|_] | _]) when is_number(scalar) do
    multiply [[scalar]], rows
  end
  def multiply(rows = [[_|_] | _], scalar) when is_number(scalar) do
    multiply rows, [[scalar]]
  end
  def multiply(row = [[_|_]], column = [[_] | _])
      when length(hd row) == length(column) do

    [[result]] = matrix_product row, column

    result
  end
  def multiply(matrix1 = [[_|_] | _], matrix2 = [[_|_] | _])
      when length(hd matrix1) == length(matrix2) do

    matrix_product matrix1, matrix2
  end
  def multiply(tensor1 = [[_|_] | _], tensor2 = [[_|_] | _]) do
    tensor_product tensor1, tensor2
  end

  @spec transpose([[number]]) :: [[number]]
  def transpose(object = [[_|_] | _]) do
    object
      |> List.zip
      |> Enum.map(&Tuple.to_list(&1))
  end


  ## Common structures ##

  defp make_matrix_of(x, n, m) do
    x
      |> List.duplicate(m)
      |> List.duplicate(n)
  end

  @spec ones(pos_integer, pos_integer) :: [[1]]
  def ones(n, m) when is_integer(n) and is_integer(m) and n >= 1 and m >= 1 do
    make_matrix_of 1, n, m
  end

  @spec identity_matrix(pos_integer) :: [[0 | 1]]
  def identity_matrix(n) when is_integer(n) and n >= 1 do
    zeros = List.duplicate 0, n

    for i <- 1..n do
      List.update_at zeros, i - 1, fn 0 -> 1 end
    end
  end

  @spec complete_graph_adjacency_matrix(pos_integer) :: [[0 | 1]]
  def complete_graph_adjacency_matrix(n) when is_integer(n) and n >= 1 do
    one = ones 1, n

    one
      |> transpose
      |> multiply(one)
      |> subtract(identity_matrix n)
  end
end
