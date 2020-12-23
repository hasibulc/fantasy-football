require 'random_word_generator'
require 'io/console'

class User < ActiveRecord::Base
    has_many :teams
    
    def username
        @prompt = TTY::Prompt.new
        puts "Welcome to Fantasy Soccer! Enter an existing username or create a new one."
        #borrowed this from Hector, Trewain, Pavel
        self.user = @prompt.ask("Enter your Username:", default: ENV['USER']) { |input| input.validate /^^(?=.{4,30}$)(?![_.])(?!.*[_.]{2})[a-zA-Z0-9._]+(?<![_.])$/, "Please enter at least 4 characters for your username, with no symbols or spaces."}
        record = User.all.find_by(user: self.user)
        if User.all.find_by(user: self.user)
            i = 0
            count = 2
            until i == 3 do
                self.password = @prompt.mask("Enter your Password: ")
                if self.password != record.password
                    puts "That password is incorrect!"
                    if count != 0
                        puts "You have #{count} attempts left."
                    else
                    end
                    i += 1
                    count -=1
                else    
                    return record
                    # exit
                end
            end
            create_new = "Create a new user"
            user_exit = "Exit"
            ar = [create_new, user_exit]
            response = @prompt.select("Create a new user or exit the program: ", ar)
            if response == create_new
                self.username
            elsif response == user_exit
                exit
            end
        else
            self.password = @prompt.mask("Enter your Password:")
            self.user_wins = 0
            self.user_losses = 0
            self.save
            return User.all.find_by(user: self.user)
        end
    end

    def new_team
        temp_team = Team.new
        temp_team.teamname
        temp_team.select_players
        temp_team.save_team
        temp_team.user_id = self.id
        temp_team.save
    end

    def my_teams
        if user_has_teams?
            found_user_team_array = user_saved_teams

            sleep(1)

            ascii_art(found_user_team_array)
            found_user_team_array
        else
            puts "You have no saved teams."
            #this is to fix tty issues
            sleep(1)
            2
        end
    end

    def vs_computer
        if user_has_teams?
            my_teams = user_saved_teams
            user_team_obj = Team.all.find_by(team_name: my_teams[0][1])
            ascii_art(my_teams)
            my_teams.shift
            average = average_team_rating(my_teams)
            team_stats = get_team_stats(my_teams)
            weighted_stat = weighted_rating(average, team_stats)

            #create computer team and calculate their math
            computer_player
            computer_team = get_computer_team
            computer_team.shift()
            computer_average = average_team_rating(computer_team)
            computer_team_stats = get_team_stats(computer_team)
            computer_weighted_stat = weighted_rating(computer_average, computer_team_stats)

            wait_for_keypress
            puts `clear`
            determine_winner(user_team_obj, average, team_stats, weighted_stat, computer_average, computer_team_stats, computer_weighted_stat)

        else
            puts "You have no saved teams."
        end
        sleep(1)
    end

    def user_saved_teams
        @prompt_my_teams = TTY::Prompt.new
        teams = Team.all.where("user_id = ?", self.id)
        team_names = teams.map {|team| team.team_name + " (Wins: " + team.team_wins.to_s + " Losses: " + team.team_losses.to_s + ")"}
        user_selected_team = @prompt_my_teams.select("Here are your teams, please select one:", team_names, filter: true)
        user_selected_team_split = user_selected_team.split(" (W")[0]
        found_user_selected_team = Team.all.find_by(team_name: user_selected_team_split, user_id: self.id)
        found_user_team_array = found_user_selected_team.attributes.to_a
        found_user_team_array.shift()
        found_user_team_array.pop(3)
        found_user_team_array
    end

    def user_has_teams?
        Team.all.where("user_id = ?", self.id).any?
    end

    def average_team_rating(team_array)
        player_objs = []
        my_teams = team_array
        my_teams.each do |item|
            player_objs << Player.all.find_by(name: item[1])
        end
        ratings = player_objs.map do |player|
            player.rating
        end
        average = (ratings.sum / ratings.length).round(2)
    end

    def get_team_stats(team_array)
        player_objs = []
        my_teams = team_array
        my_teams.each do |item|
            player_objs << Player.all.find_by(name: item[1])
        end
        goals_scored = player_objs.map do |player|
            player.goals_scored
        end
        goals_conceded = player_objs.map do |player|
            player.goals_conceded
        end
        goals_assisted = player_objs.map do |player|
            player.goals_assisted
        end

        goals_scored.sum - goals_conceded.sum + goals_assisted.sum
    end

    def weighted_rating(average, team_stats)
        if team_stats < 0
            if team_stats < -29
                team_stats = -29
            end
            (average * (1 + team_stats/30.0)).round(1)
        elsif team_stats > 0
            (average * (1 + team_stats/30.0)).round(1)
        end
    end

    def computer_player
        temp_team = Team.new
        temp_team.team_name = auto_teamname
        computer_team = temp_team.auto_select_players
        temp_team.save_team(computer_team)
        temp_team.save
    end

    def auto_teamname
        RandomWordGenerator.composed(2, 15)
    end

    def get_computer_team
        computer_team = Team.last
        found_user_selected_team = computer_team
        found_user_team_array = found_user_selected_team.attributes.to_a
        found_user_team_array.shift()
        puts "Computer's team name: #{found_user_team_array[0][1]}"
        sleep (1)
        puts "Computer will begin selecting players!"
        puts " "
        found_user_team_array.shift()
        found_user_team_array.pop(3)
        sleep(1)

        counter = 1
        found_user_team_array.each do |attribute|
            
            sleep(1)
            slow_print_message("Picking Player #{counter}... \n", 0.03)

            puts attribute[1]
            puts " "
          
            counter += 1
        end
        found_user_team_array
    end 

    def slow_print_message(message, speed)
        message.each_char do |x|
       sleep (speed); print x
        end
    end

    def vs_saved_teams
        prompt_all_teams = TTY::Prompt.new
        #user's team
        teams = Team.all
        team_names = teams.map {|team| team.team_name}
        user_selected_team = prompt_all_teams.select("Select your opponent:", team_names, filter: true)
        user_selected_team_obj = teams.find_by(team_name: user_selected_team)
        user_selected_team_obj
        #user's opponent
    end

    def self.comparing_teams(home_team, away_team)
        computer_team = Team.last
        found_user_selected_team = computer_team
        found_user_team_array = found_user_selected_team.attributes.to_a
        found_user_team_array.shift()
        puts "Computer's team name: #{found_user_team_array[0][1]}"
        sleep (1)
        puts "Computer will begin selecting players!"
        puts " "
        found_user_team_array.shift()
        found_user_team_array.pop(3)
        sleep(1)

        counter = 1
        found_user_team_array.each do |attribute|
            
            sleep(1)
            slow_print_message("Picking Player #{counter}... \n", 0.05)

            puts attribute[1]
            puts " "

            counter += 1
        end
        found_user_team_array
    end

    def determine_winner(user_team_obj, user_team_avg, user_team_stats, user_weighted_stat, comp_team_avg, comp_team_stats, comp_weighted_stat, opp_team_obj = 0)
        sleep (1)
        
        chance_of_winning = user_weighted_stat / (user_weighted_stat + comp_weighted_stat)
        random_number = rand(0.0..1.0)

        puts "Here is your teams average: #{user_team_avg}"
        puts "Here is the opponent's team average: #{comp_team_avg}"
        puts " "
        sleep (2)
        puts "Here is your teams stat: #{user_team_stats}"
        puts "Here is the opponent's team stat: #{comp_team_stats}"
        puts " "
        sleep (2)
        puts "Here is your weighted team rating: #{user_weighted_stat}"
        puts "Here is the opponent's weighted team rating: #{comp_weighted_stat}"
        puts " "
        sleep (2)
        puts "*" * 25
        puts "Your chance of winning against the opposing team is: #{(chance_of_winning*100).round(2)}%"

        puts "The crowd roars and the match begins!".colorize(:green)

        #flash simulating game
        flash_text

        #did the user win????
        # puts random_number
        if random_number < chance_of_winning
            if opp_team_obj == 0
                self.user_wins += 1
                user_team_obj.team_wins += 1
                user_team_obj.save
                self.save
                puts "YOU WIN!🥳".light_green.blink
            else
                self.user_wins += 1
                user_team_obj.team_wins += 1
                opp_team_obj.team_losses += 1
                user_team_obj.save
                opp_team_obj.save
                self.save
                puts "YOU WIN!🥳".light_green.blink
            end
        else
            if opp_team_obj == 0
                self.user_losses += 1
                user_team_obj.team_losses += 1
                user_team_obj.save
                self.save
                puts "YOU LOSE!😭".light_red.blink
            else
                self.user_losses += 1
                user_team_obj.team_losses += 1
                opp_team_obj.team_wins += 1
                user_team_obj.save
                opp_team_obj.save
                self.save
                puts "YOU LOSE!😭".light_red.blink
            end
        end
        wait_for_keypress
    end

    #wait for keypress
    def wait_for_keypress
        print "Press any key to continue:"
        STDIN.getch
        print "\n" # extra space to overwrite in case next sentence is short
    end
    
    def ascii_art(array_of_db_players)
        ar_player_names = array_of_db_players.map {|player| player[1]}

        # puts ar_player_initials
        p1 = ar_player_names[1]
        if p1.split.length > 1
            p1_f = p1.split[0][0]
            p1_l = p1.split[-1][0]
        else 
            p1_f = p1.split[0][0]
            p1_l = " "
        end
        
        p2 = ar_player_names[2]
        if p2.split.length > 1
            p2_f = p2.split[0][0]
            p2_l = p2.split[-1][0]
        else 
            p2_f = p2.split[0][0]
            p2_l = " "
        end

        p3 = ar_player_names[3]
        if p3.split.length > 1
            p3_f = p3.split[0][0]
            p3_l = p3.split[-1][0]
        else 
            p3_f = p3.split[0][0]
            p3_l = " "
        end
        
        p4 = ar_player_names[4]
        if p4.split.length > 1
            p4_f = p4.split[0][0]
            p4_l = p4.split[-1][0]
        else 
            p4_f = p4.split[0][0]
            p4_l = " "
        end

        p5 = ar_player_names[5]
        if p5.split.length > 1
            p5_f = p5.split[0][0]
            p5_l = p5.split[-1][0]
        else 
            p5_f = p5.split[0][0]
            p5_l = " "
        end

        p6 = ar_player_names[6]
        if p6.split.length > 1
            p6_f = p6.split[0][0]
            p6_l = p6.split[-1][0]
        else 
            p6_f = p6.split[0][0]
            p6_l = " "
        end

        p7 = ar_player_names[7]
        if p7.split.length > 1
            p7_f = p7.split[0][0]
            p7_l = p7.split[-1][0]
        else 
            p7_f = p7.split[0][0]
            p7_l = " "
        end

        p8 = ar_player_names[8]
        if p8.split.length > 1
            p8_f = p8.split[0][0]
            p8_l = p8.split[-1][0]
        else 
            p8_f = p8.split[0][0]
            p8_l = " "
        end

        p9 = ar_player_names[9]
        if p9.split.length > 1
            p9_f = p9.split[0][0]
            p9_l = p9.split[-1][0]
        else 
            p9_f = p9.split[0][0]
            p9_l = " "
        end

        p10 = ar_player_names[10]
        if p10.split.length > 1
            p10_f = p10.split[0][0]
            p10_l = p10.split[-1][0]
        else 
            p10_f = p10.split[0][0]
            p10_l = " "
        end

        p11 = ar_player_names[11]
        if p11.split.length > 1
            p11_f = p11.split[0][0]
            p11_l = p11.split[-1][0]
        else 
            p11_f = p11.split[0][0]
            p11_l = " "
        end

        puts " #{ar_player_names[1]} ⚽️ #{ar_player_names[2]} ⚽️ #{ar_player_names[3]} ⚽️ #{ar_player_names[4]}"
        puts " #{ar_player_names[5]} ⚽️ #{ar_player_names[6]} ⚽️ #{ar_player_names[7]}"
        puts " #{ar_player_names[8]} ⚽️ #{ar_player_names[9]} ⚽️ #{ar_player_names[10]} ⚽️ #{ar_player_names[11]}"
        puts "           _          _          _          _          _            "
        puts "          |.|        |.|        |.|        |.|        |.|           "
        puts "          ]^[        ]^[        ]^[        ]^[        ]^[           "
        puts "        /~`-'~\\    /~`-'~\\    /~`-'~\\    /~`-'~\\    /~`-'~\\    "
        puts "       {<|#{p1_f+p1_l} |>}  {<|#{p2_f+p2_l} |>}  {<|#{p3_f+p3_l} |>}  {<|#{p4_f+p4_l} |>}  {<|#{p5_f+p5_l} |>}        "
        puts "        \\|___|/    \\|___|/    \\|___|/    \\|___|/    \\|___|/    "
        puts "        /\\    \\     /   \\      /   \\      /   \\      /   \\    "
        puts "       |/>/|__\\    /__|__\\    /__|__\\    /__|__\\    /__|__\\    "
        puts "      _|)   \\ |    | / \\ |    | / \\ |    | / \\ |    | / \\ |    "
        puts "     (_,|    \\)    (/   \\)    (/   \\)    (/   \\)    (/   \\)    "
        puts "     / \\     (|_  _|)   (|_  _|)   (|_  _|)   (|_  _|)   (|_       "
        puts ".,.,.\\_/,...,|,_)(_,|,.,|,_)(_,|,.,|,_)(_,|,.,|,_)(_,|,.,|,_).,.,.     "
        puts "      _          _          _          _          _          _            "
        puts "     |.|        |.|        |.|        |.|        |.|        |.|           "
        puts "     ]^[        ]^[        ]^[        ]^[        ]^[        ]^[           "
        puts "   /~`-'~\\    /~`-'~\\    /~`-'~\\    /~`-'~\\    /~`-'~\\    /~`-'~\\    "
        puts "  {<|#{p6_f+p6_l} |>}  {<|#{p7_f+p7_l} |>}  {<|#{p8_f+p8_l} |>}  {<|#{p9_f+p9_l} |>}  {<|#{p10_f+p10_l} |>}  {<|#{p11_f+p11_l} |>}        "
        puts "   \\|___|/    \\|___|/    \\|___|/    \\|___|/    \\|___|/    \\|___|/    "
        puts "   /\\    \\     /   \\      /   \\      /   \\      /   \\      /   \\    "
        puts "  |/>/|__\\    /__|__\\    /__|__\\    /__|__\\    /__|__\\    /__|__\\    "
        puts " _|)   \\ |    | / \\ |    | / \\ |    | / \\ |    | / \\ |    | / \\ |    "
        puts "(_,|    \\)    (/   \\)    (/   \\)    (/   \\)    (/   \\)    (/   \\)    "
        puts "/ \\     (|_  _|)   (|_  _|)   (|_  _|)   (|_  _|)   (|_  _|)   (|_       "
        puts "\\_/,...,|,_)(_,|,.,|,_)(_,|,.,|,_)(_,|,.,|,_)(_,|,.,|,_)(_,|,.,|,_)     "
        wait_for_keypress
        puts `clear`
    end

    def flash_text
        5.times do
            STDOUT.print "\rSimulating Game..."
            sleep 0.5
            STDOUT.print "\r                  "
            sleep 0.5
        end
        puts " "
    end

    def calculate_wins_losses
        puts "You have won #{self.user_wins} game(s).".light_green
        puts "You have lost #{self.user_losses} game(s).".light_red

        if (self.user_wins + self.user_losses) > 0 
            win_rate = (self.user_wins.to_f/(self.user_wins + self.user_losses))*100
            win_rate = win_rate.round(2)
            if win_rate >= 75.0
                puts "\nYour win rate is #{win_rate}%\n".green
            elsif win_rate.between?(50.0,74.99)
                puts "\nYour win rate is #{win_rate}%\n".light_green
            elsif win_rate.between?(25.0,49.99)
                puts "\nYour win rate is #{win_rate}%\n".light_red
            elsif win_rate.between?(0.0,24.99)
                puts "\nYour win rate is #{win_rate}%\n".red
            end
        else
            puts "\nPlease play a game! \n".yellow.blink
        end
        wait_for_keypress
    end

    def calculate_vs_other_team(user_select_team)
        if user_select_team == 2
            #this does nothing
        else #user_select_team == 1
            opponent_team = self.vs_saved_teams
            opponent_team_ar = opponent_team.attributes.to_a
            user_team_obj = Team.all.find_by(team_name: user_select_team[0][1])
            user_select_team.shift
            
            #remove team id for ascii art then remove teamname for math stuff
            opponent_team_ar.shift(1)
            opponent_team_ar.pop(3)
            self.ascii_art(opponent_team_ar)
            opponent_team_ar.shift(1)
    
            average = self.average_team_rating(user_select_team)
            team_stats = self.get_team_stats(user_select_team)
            weighted_stat = self.weighted_rating(average, team_stats)
    
            opp_average = self.average_team_rating(opponent_team_ar)
            opp_team_stats = self.get_team_stats(opponent_team_ar)
            opp_weighted_stat = self.weighted_rating(opp_average, opp_team_stats)
            
            #present the stats
            self.determine_winner(user_team_obj, average, team_stats, weighted_stat, opp_average, opp_team_stats, opp_weighted_stat, opponent_team)
        end
    end

end