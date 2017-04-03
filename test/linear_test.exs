# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

defmodule LinearTest do
  use ExUnit.Case, async: true

  import Linear

  test "Adds two row vectors" do
    v = [[1, 2, 3]]

    assert add(v, v) == [[2, 4, 6]]
  end

  test "Adds two column vectors" do
    v = [[1], [2], [3]]

    assert add(v, v) == [[2], [4], [6]]
  end

  test "Adds two matrices" do
    i = Linear.identity_matrix 3

    assert add(i, i) ==
      [ [2, 0, 0],
        [0, 2, 0],
        [0, 0, 2]
      ]
  end

  test "Subtracts two row vectors" do
    v = [[1, 2, 3]]

    assert subtract(v, v) == [[0, 0, 0]]
  end

  test "Subtracts two column vectors" do
    v = [[1], [2], [3]]

    assert subtract(v, v) == [[0], [0], [0]]
  end

  test "Subtracts two matrices" do
    i = Linear.identity_matrix 3

    assert subtract(i, i) ==
      [ [0, 0, 0],
        [0, 0, 0],
        [0, 0, 0]
      ]
  end

  test "Transposes a row vector" do
    v = [[1, 2, 3]]

    assert transpose(v) == [[1], [2], [3]]
  end

  test "Transposes a column vector" do
    v = [[1], [2], [3]]

    assert transpose(v) == [[1, 2, 3]]
  end

  test "Transposes an nxm matrix" do
    nxm =
      [ [1, 2],
        [3, 4],
        [5, 6]
      ]

    assert transpose(nxm) ==
      [ [1, 3, 5],
        [2, 4, 6]
      ]
  end

  test "Implicitly multiplies two scalars" do
    assert multiply(2, 3) == 6
  end

  test "Implicitly multiplies a scalar and a row vector" do
    assert multiply(2, [[1, 1, 1]]) == [[2, 2, 2]]
  end

  test "Implicitly multiplies a row vector and a scalar" do
    assert multiply([[1, 1, 1]], 2) == [[2, 2, 2]]
  end

  test "Implicitly multiplies a scalar and a column vector" do
    assert multiply(2, [[1], [1], [1]]) == [[2], [2], [2]]
  end

  test "Implicitly multiplies a column vector and a scalar" do
    assert multiply([[1], [1], [1]], 2) == [[2], [2], [2]]
  end

  test "Implicitly multiplies a scalar and a matrix" do
    i = Linear.identity_matrix 3

    assert multiply(2, i) ==
      [ [2, 0, 0],
        [0, 2, 0],
        [0, 0, 2]
      ]
  end

  test "Implicitly multiplies a matrix and a scalar" do
    i = Linear.identity_matrix 3

    assert multiply(i, 2) ==
      [ [2, 0, 0],
        [0, 2, 0],
        [0, 0, 2]
      ]
  end

  test "Implicitly takes the tensor product of a row vector and a row vector" do
    v = [[1, 2, 3]]

    assert multiply(v, v) == [[1, 2, 3, 2, 4, 6, 3, 6, 9]]
  end

  test "Implicitly takes the tensor product of a column vector and a row vector" do
    v = [[1, 2, 3]]

    assert multiply(transpose(v), v) ==
      [ [1, 2, 3],
        [2, 4, 6],
        [3, 6, 9]
      ]
  end

  test "Implicitly takes the tensor product of a column vector and a column vector" do
    v = [[1], [2], [3]]

    assert multiply(v, v) == [[1], [2], [3], [2], [4], [6], [3], [6], [9]]
  end

  test "Implicitly takes the tensor product of a column vector and a matrix" do
    v = [[1], [1], [1]]
    i = Linear.identity_matrix 3

    assert multiply(v, i) == i ++ i ++ i
  end

  test "Implicitly takes the tensor product of a matrix and a row vector" do
    i = Linear.identity_matrix 3
    zeros = [0, 0, 0]
    ones  = [1, 1, 1]

    assert multiply(i, [ones]) ==
      [ ones  ++ zeros ++ zeros,
        zeros ++ ones  ++ zeros,
        zeros ++ zeros ++ ones
      ]
  end

  test "Implicitly takes the matrix product of an nxm matrix and an mxn matrix to be an nxn matrix" do
    nxm =
      [ [1, 0, 0],
        [0, 1, 0]
      ]

    mxn =
      [ [1, 0],
        [0, 1],
        [0, 0]
      ]

    assert multiply(nxm, mxn) ==
      [ [1, 0],
        [0, 1]
      ]
  end

  test "Implicitly takes the matrix product of two mxm matrices" do
    i = identity_matrix 3
    m =
      [ [1, 2, 3],
        [4, 5, 6],
        [7, 8, 9]
      ]

    assert multiply(i, m) == m
    assert multiply(m, i) == m
  end

  test "Implicitly takes the tensor product of an nxn matrix and a pxn matrix" do
    nxn =
      [ [1, 0],
        [0, 1]
      ]

    pxn =
      [ [1, 0],
        [0, 1],
        [0, 0]
      ]

    assert multiply(nxn, pxn) ==
      [ [1, 0, 0, 0],
        [0, 1, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 1, 0],
        [0, 0, 0, 1],
        [0, 0, 0, 0]
      ]
  end

  test "Implicitly takes the dot product of a row vector and a column vector" do
    u = [[1, 2, 3]]
    v = [[1], [2], [3]]

    assert multiply(u, v) == 1*1 + 2*2 + 3*3
  end

  test "Implicitly takes the matrix product of a row vector and the identity matrix" do
    v = [[1, 2, 3]]
    i = identity_matrix 3

    assert multiply(v, i) == v
  end

  test "Implicitly takes the matrix product of the identity matrix and a column vector" do
    i = identity_matrix 3
    v = [[1], [2], [3]]

    assert multiply(i, v) == v
  end

  test "Explicitly takes the tensor product of a row vector and a matrix" do
    v = [[1, 1, 1]]
    i = identity_matrix 3

    assert tensor_product(v, i) ==
      [ [1, 0, 0, 1, 0, 0, 1, 0, 0],
        [0, 1, 0, 0, 1, 0, 0, 1, 0],
        [0, 0, 1, 0, 0, 1, 0, 0, 1]
      ]
  end

  test "Explicitly takes the tensor product of a matrix and a column vector" do
    i = identity_matrix 3
    v = [[1], [1], [1]]

    assert tensor_product(i, v) ==
      [ [1, 0, 0],
        [1, 0, 0],
        [1, 0, 0],
        [0, 1, 0],
        [0, 1, 0],
        [0, 1, 0],
        [0, 0, 1],
        [0, 0, 1],
        [0, 0, 1]
      ]
  end
end
