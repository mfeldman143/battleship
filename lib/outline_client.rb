# Copyright 2017 Google Inc.
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at

#      http://www.apache.org/licenses/LICENSE-2.0

# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "net/http"
require_relative "client.rb"
require "json"
require "pp"

SERVER = "http://localhost:3000"

c = Client.new
c.place_ships

# Get a Game ID
uri = URI("#{SERVER}/new_game")

response = Net::HTTP.get(uri)

game_id = JSON.parse(response)["game_id"]

opponent_move = {}

# Moves!
loop do
  # Build my turn
  request = {game_id: game_id}

  request[:response] = {}

  unless opponent_move.empty?
    exit if opponent_move["response"]["lost"]

    results = c.process_move opponent_move["guess"]["guess"]

    request[:response] = results
    request[:response][:lost] = c.lost?
  end

  request[:guess] = { guess: c.guess }

  puts "Client"
  pp request

  # Send Move
  uri = URI("#{SERVER}/turn")

  # exit if c.lost?

  response = Net::HTTP.post(uri,
                            request.to_json,
                            "Content-Type" => "application/json")

  # Parse response
  opponent_move = JSON.parse(response.body)

  puts "Server"
  pp opponent_move
end
