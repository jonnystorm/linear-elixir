# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

defmodule MatrixTest do
  use ExUnit.Case, async: true

  test "Adds two matrices" do
    a =
      [ [1, 0, 0],
        [0, 1, 0],
        [0, 0, 1],
        [1, 1, 1]
      ]

    a2 =
      [ [2, 0, 0],
        [0, 2, 0],
        [0, 0, 2],
        [2, 2, 2]
      ]

    assert Matrix.add(a, a) == a2
  end

  test "Subtracts two matrices" do
    a =
      [ [1, 0, 0],
        [0, 1, 0],
        [0, 0, 1],
        [1, 1, 1]
      ]

    zero =
      [ [0, 0, 0],
        [0, 0, 0],
        [0, 0, 0],
        [0, 0, 0]
      ]

      assert Matrix.subtract(a, a) == zero
  end

  test "Multiplies an nxm matrix by a scalar" do
    a =
      [ [1, 0, 0],
        [0, 1, 0],
        [0, 0, 1],
        [1, 1, 1]
      ]

    a2 =
      [ [2, 0, 0],
        [0, 2, 0],
        [0, 0, 2],
        [2, 2, 2]
      ]

    assert Matrix.multiply(a, 2) == a2
  end

  test "Multiplies an nxm matrix by an nx1 column vector" do
    v =
      [ [1],
        [2],
        [3]
      ]

    a =
      [ [1, 0, 0],
        [0, 1, 0],
        [0, 0, 1],
        [1, 1, 1]
      ]

    assert Matrix.multiply(a, v) == [[1], [2], [3], [6]]
  end

  test "Fails to multiply an nxm matrix by an (n+1)x1 column vector" do
    v =
      [ [1],
        [2],
        [3],
        [4]
      ]

    a =
      [ [1, 0, 0],
        [0, 1, 0],
        [0, 0, 1],
        [1, 1, 1]
      ]

    assert_raise ArgumentError, fn ->
      Matrix.multiply(a, v)
    end
  end

  test "Fails to multiply an nxn matrix by an (n-1)x1 column vector" do
    v =
      [ [1],
        [2]
      ]

    a =
      [ [1, 0, 0],
        [0, 1, 0],
        [0, 0, 1],
        [1, 1, 1]
      ]

    assert_raise ArgumentError, fn ->
      Matrix.multiply(a, v)
    end
  end

  test "Transposes an nxm matrix" do
    a =
      [ [1, 0, 0],
        [0, 1, 0],
        [0, 0, 1],
        [1, 1, 1]
      ]

    a_transpose =
      [ [1, 0, 0, 1],
        [0, 1, 0, 1],
        [0, 0, 1, 1]
      ]

    assert Matrix.transpose(a) == a_transpose
  end
end
