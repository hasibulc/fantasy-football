Player.destroy_all

all_players = []
real_madrid = Unirest.get "https://api-football-v1.p.rapidapi.com/v2/players/team/541/2018-2019",
 headers:{
   "X-RapidAPI-Host" => "api-football-v1.p.rapidapi.com",
   "X-RapidAPI-Key" => "API_KEY_GOES_HERE"
 }
barcelona = Unirest.get "https://api-football-v1.p.rapidapi.com/v2/players/team/529/2018-2019",
 headers:{
   "X-RapidAPI-Host" => "api-football-v1.p.rapidapi.com",
   "X-RapidAPI-Key" => "API_KEY_GOES_HERE"
 }
man_utd = Unirest.get "https://api-football-v1.p.rapidapi.com/v2/players/team/33/2018-2019",
 headers:{
   "X-RapidAPI-Host" => "api-football-v1.p.rapidapi.com",
   "X-RapidAPI-Key" => "API_KEY_GOES_HERE"
 }
man_city = Unirest.get "https://api-football-v1.p.rapidapi.com/v2/players/team/50/2018-2019",
 headers:{
   "X-RapidAPI-Host" => "api-football-v1.p.rapidapi.com",
   "X-RapidAPI-Key" => "API_KEY_GOES_HERE"
 }
liverpool = Unirest.get "https://api-football-v1.p.rapidapi.com/v2/players/team/40/2018-2019",
 headers:{
   "X-RapidAPI-Host" => "api-football-v1.p.rapidapi.com",
   "X-RapidAPI-Key" => "API_KEY_GOES_HERE"
 }
psg = Unirest.get "https://api-football-v1.p.rapidapi.com/v2/players/team/85/2018-2019",
 headers:{
   "X-RapidAPI-Host" => "api-football-v1.p.rapidapi.com",
   "X-RapidAPI-Key" => "API_KEY_GOES_HERE"
 }
bayern = Unirest.get "https://api-football-v1.p.rapidapi.com/v2/players/team/157/2018-2019",
 headers:{
   "X-RapidAPI-Host" => "api-football-v1.p.rapidapi.com",
   "X-RapidAPI-Key" => "API_KEY_GOES_HERE"
 }
dortmund = Unirest.get "https://api-football-v1.p.rapidapi.com/v2/players/team/165/2018-2019",
 headers:{
   "X-RapidAPI-Host" => "api-football-v1.p.rapidapi.com",
   "X-RapidAPI-Key" => "API_KEY_GOES_HERE"
 }
atletico = Unirest.get "https://api-football-v1.p.rapidapi.com/v2/players/team/530/2018-2019",
 headers:{
   "X-RapidAPI-Host" => "api-football-v1.p.rapidapi.com",
   "X-RapidAPI-Key" => "API_KEY_GOES_HERE"
 }
chelsea = Unirest.get "https://api-football-v1.p.rapidapi.com/v2/players/team/49/2018-2019",
 headers:{
   "X-RapidAPI-Host" => "api-football-v1.p.rapidapi.com",
   "X-RapidAPI-Key" => "API_KEY_GOES_HERE"
 }
all_teams = [real_madrid, barcelona, man_utd, man_city, liverpool, psg, bayern, dortmund, atletico, chelsea]
all_players = []
all_goals = []
all_teams.each do |team|
   team.body["api"]["players"].each do |player|
       rating = {}
       all_players << player["player_name"]
       rating["goals"] = player["goals"]
       rating["rating"] = player["rating"]
       all_goals << rating
       end
   end
hash_all_players = all_players.zip(all_goals).to_h
filtered_all_players = hash_all_players.select {|key, value| hash_all_players[key]["rating"] != nil}

filtered_all_players.each {|key, value| player = Player.new;
 player.name = key;
 player.goals_scored = value["goals"]["total"];
 player.goals_conceded = value["goals"]["conceded"];
 player.goals_assisted = value["goals"]["assists"];
 player.rating = value["rating"]
 player.save
}
