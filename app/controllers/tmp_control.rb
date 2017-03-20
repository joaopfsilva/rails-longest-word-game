require 'open-uri'
require 'json'
require 'pp'

def generate_grid(grid_size)
  # TODO: generate random grid of letters
  return (0...grid_size).map { ('A'..'Z').to_a[rand(26)] }
end


def run_game(attempt, grid, start_time, end_time)
  # TODO: runs the game and return detailed hash of result
  unless in_grid?(attempt.upcase.split(""), grid.join("").upcase.split(""))
    return { time: 0, translation: nil, score: 0, message: "not in the grid" }
  end

  word_fr, is_error = get_word_translated(attempt)
  raise if is_error

  score = get_score(word_fr, attempt, end_time - start_time)
  end_time, start_time, word_fr, score, msg = msg_error("not an english word") if attempt == word_fr

  { time: end_time - start_time, translation: word_fr, score: score, message: score >= 6.8 ? "well done" : msg }

rescue
  puts word_fr
end

def msg_error(msg)
  return 0, 0, nil, 0, msg
end


def in_grid?(attempt, grid)
  counts_grid = Hash.new 0
  grid.each { |word| counts_grid[word] += 1 }

  attempt.each do |w|
    if substring_in_string?(w, counts_grid)
      counts_grid[w] -= 1
    else
      return false
    end
  end
  return true
end


def substring_in_string?(word, counts_grid)
  if !counts_grid.key? word
    return false
  elsif counts_grid[word].zero?
    return false
  else
    return true
  end
end


def get_score(word_fr, word_en, time_taken)
  word_fr.length / (time_taken + (1 / word_fr.length))
end

def get_word_translated(word)
  url = 'https://api-platform.systran.net/translation/text/translate?source=en&target=fr'
  url << '&key=b987a571-b766-40ec-8986-a995c46a2cdf'
  url << "&input=#{word}"
  uri = URI(url)

  info = JSON.parse(uri.read)

  return info["outputs"][0]["output"], false if info.key? "outputs"

  return info["error"][0]["message"], true
end


##########

require_relative "longest_word"

puts "******** Welcome to the longest word-game !********"
puts "Here is your grid :"
grid = generate_grid(9)
puts grid.join(" ")
puts "*****************************************************"

puts "What's your best shot ?"
start_time = Time.now
attempt = gets.chomp
end_time = Time.now

puts "******** Now your result ********"

result = run_game(attempt, grid, start_time, end_time)

puts "Your word: #{attempt}"
puts "Time Taken to answer: #{result[:time]}"
puts "Translation: #{result[:translation]}"
puts "Your score: #{result[:score]}"
puts "Message: #{result[:message]}"

puts "*****************************************************"












