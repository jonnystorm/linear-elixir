# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

defprotocol Matrix do
  def dimension(object)
  def add(object1, object2)
  def subtract(object1, object2)
  def multiply(object1, object2)
  def transpose(object)
end

defimpl Matrix, for: List do
  def dimension(object = [row|_]) when is_list(row),
    do: {length(object), length(row)}

  def add(object1 = [row1|_], object2 = [row2|_])
      when is_list(row1) and is_list(row2)
  do
    object1
    |> Enum.zip(object2)
    |> Enum.map(fn {row1, row2} ->
      Vector.add(row1, row2)
    end)
  end

  def subtract(object1 = [row1|_], object2 = [row2|_])
      when is_list(row1) and is_list(row2)
  do
    object2
    |> multiply(-1)
    |> add(object1)
  end

  def multiply(object1 = [row|_], object2 = [row2|_])
      when is_list(row) and is_list(row2)
  do
    for row <- object1 do
      for col <- transpose(object2) do
        Vector.inner(row, col)
      end
    end
  end

  def multiply(object = [row|_], row_vector)
      when is_list(row) and is_list(row_vector),
    do: multiply(object, transpose([row_vector]))

  def multiply(object = [row|_], scalar)
      when is_list(row) and is_number(scalar)
  do
    for row <- object do
      Vector.multiply(row, scalar)
    end
  end

  def transpose(object = [row|_]) when is_list row do
    object
    |> List.zip
    |> Enum.map(&(Tuple.to_list &1))
  end

  def transpose(row_vector),
    do: transpose [row_vector]
end
