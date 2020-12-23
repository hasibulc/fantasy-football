class Team < ActiveRecord::Base
    belongs_to :user

    def teamname
        @name = ""
        while @name == "" or @name == " " do
            print "Enter a team name with at least 1 character: "
            @name = gets.chomp 
            self.team_name = @name
        end
    end

    def select_players
        @prompt = TTY::Prompt.new
        player_array = Player.all.map do |player|
            empty_ar = []
            empty_ar << player.name
            empty_ar << "Goals Scored: " + player.goals_scored.to_s
            empty_ar << "Goals Conceded: " + player.goals_conceded.to_s
            empty_ar << "Goals Assisted: " + player.goals_assisted.to_s
            empty_ar << player.rating
        end

        name_array = player_array.map do |player|
            player[0] + "\n       " + player[1] + "\n       " + player[2] + "\n       " + player[3]
        end

        @my_team = []
        i = 1
        11.times do 
            my_player = @prompt.select("Choose Player #{i}", name_array, filter: true)
            player_full_name = my_player.split("\n")
            @my_team << player_full_name[0]
            name_array.delete(my_player)
            i+=1
            puts `clear`
        end

        #flashes CREATING TEAM...
        5.times do
            STDOUT.print "\rCreating Team..."
            sleep 0.25
            STDOUT.print "\r                "
            sleep 0.25
        end

        @my_team
    end

    def save_team(my_team = nil)
        num = 1
        i = 1

        self.player1 = @my_team[0]
        self.player2 = @my_team[1]
        self.player3 = @my_team[2]
        self.player4 = @my_team[3]
        self.player5 = @my_team[4]
        self.player6 = @my_team[5]
        self.player7 = @my_team[6]
        self.player8 = @my_team[7]
        self.player9 = @my_team[8]
        self.player10 = @my_team[9]
        self.player11 = @my_team[10]
        
        #wins and losses
        self.team_wins = 0
        self.team_losses = 0
        # self.save
    end

    def auto_select_players
        #array of all player and stats
        player_array = Player.all.map do |player|
            empty_ar = []
            empty_ar << player.name
            empty_ar << "Goals Scored: " + player.goals_scored.to_s
            empty_ar << "Goals Conceded: " + player.goals_conceded.to_s
            empty_ar << "Goals Assisted: " + player.goals_assisted.to_s
            empty_ar << player.rating
        end

        #randomly select 11 players
        @my_team = []
        11.times do 
            my_player = player_array.sample
            player_full_name = my_player.split("\n")
            @my_team << player_full_name[0][0]
            player_array.delete(my_player)
        end
        @my_team
    end

end