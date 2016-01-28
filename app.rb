require "sinatra"
require "sinatra/reloader"
enable :sessions
use Rack::MethodOverride

get "/" do
  erb :index, layout: :application
end

post "/team_picker" do
  @names = session[:names] = params[:names].to_s
  @method = session[:method] = params[:method].to_s
  @number = session[:number] = params[:number].to_i

  names = @names.split(",")
  if (names.length < @number)
    @error = true
  else
    names.shuffle!
    i=1
    teams = []
    groups = []

    if @method == "team_count"
      groups = in_groups(names, @number)

      groups.each do |a|
        a.compact!
        teams << "Team #{i}: #{a}" + "\n"
        i += 1
      end
    elsif @method == "per_team"
      names.each_slice(@number) do |a|
        teams << "Team #{i}: #{a}" + "\n"
        i += 1
      end
    end
  end

  @result = teams
  erb :index, layout: :application
end

def in_groups(a, number, fill_with = nil)

  division = a.size.div number
  modulo = a.size % number

  groups = []
  start = 0

  number.times do |index|
    length = division + (modulo > 0 && modulo > index ? 1 : 0)
    groups << last_group = a.slice(start, length)
    last_group << fill_with if fill_with != false &&
      modulo > 0 && length == division
    start += length
  end

  if block_given?
    groups.each { |g| yield(g) }
  else
    groups
  end
end
