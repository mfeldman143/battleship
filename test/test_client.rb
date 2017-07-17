# Copyright 2017 Google
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at

#      http://www.apache.org/licenses/LICENSE-2.0

# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require_relative '../lib/client'
require 'minitest/autorun'

class TestClient < Minitest::Test
  def test_initialize
    c = Client.new("gameID", [[:battleship, 5]])

    assert_equal "gameID", c.game_id
    assert_equal [[:battleship, 5]], c.fleet

    assert c.my_board
    assert c.their_board
  end

  def test_place_ship
    c = Client.new("gameID", [])

    c.place_ship :cruiser, 3

    assert_equal 3, c.my_board.to_s.each_char.count { |l| l == "c" }
  end

  def test_place_ships
    c = Client.new("gameID", [[:battleship, 5],
                              [:cruiser, 4],
                              [:submarine, 3],
                              [:frigate, 3],
                              [:destroyer, 2]])

    c.place_ships

    assert_equal 5, c.my_board.to_s.each_char.count { |l| l == "b" }
    assert_equal 4, c.my_board.to_s.each_char.count { |l| l == "c" }
    assert_equal 3, c.my_board.to_s.each_char.count { |l| l == "s" }
    assert_equal 3, c.my_board.to_s.each_char.count { |l| l == "f" }
    assert_equal 2, c.my_board.to_s.each_char.count { |l| l == "d" }
  end

  def test_guess
    c = Client.new()

    g = c.guess

    assert c.their_board.in_range?(g)
  end

  def test_process_move
    c = Client.new("gameID", [[:destroyer, 2]])

    c.my_board["A7"] = :destroyer
    c.my_board["A8"] = :destroyer

    assert_equal false, c.process_move("F3")[:hit]
    assert_equal true,  c.process_move("A7")[:hit]

    # assert_equal {:hit => false}, c.process_move("F3")
    # assert_equal {:hit => true}, c.process_move("A7")
    # assert_equal {:hit => true,
    #               :sunk => :destroyer}, c.process_move("A8")
  end
end
