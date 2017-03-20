class GamesController < ApplicationController

  @grid = ""

  def game
    @grid = generate_grid(9)
  end

  def score
    @result = run_game(params[:attempt], params[:grid], params[:starttime], Time.now)
    @output = {}
    if @result.class == String
      @output[:msg] = @result
      @output[:score] = 0
      @output[:time] = 0
    elsif @result == params[:attempt]
      @output.msg = "No translation available!"
      @output[:score] = 0
      @output[:time] = @result.fetch(:time, 0)
    elsif !@result.fetch(:translation, @result)
      @output.msg = @result.fetch(:message, "")
      @output[:score] = 0
      @output[:time] = @result.fetch(:time, @result)
    else
      @output.msg = @result.fetch(:translation, @result)
      @output[:time] = @result.fetch(:time, 0)
      @output[:score] = @result.fetch(:score, 0)
    end
  end


  def generate_grid(grid_size)
    return (0...grid_size).map { ('A'..'Z').to_a[rand(26)] }
  end

  def run_game(attempt, grid, start_time, end_time)
    grid = grid.split(",")
    unless in_grid?(attempt.upcase.split(""), grid.join("").upcase.split(""))
      return { time: 0, translation: nil, score: 0, message: "not in the grid" }
    end
    word_fr, is_error = get_word_translated(attempt)
    raise if is_error

    score = get_score(word_fr, attempt, end_time - start_time)
    end_time, start_time, word_fr, score, msg = msg_error("not an english word") if attempt == word_fr

    { time: end_time - start_time, translation: word_fr, score: score, message: score >= 6.8 ? "well done" : msg }

  rescue
    return word_fr
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
end
