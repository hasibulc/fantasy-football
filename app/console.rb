def console
    puts `clear`
    startup_ascii_art
    my_username = greetings
    @console_prompt = TTY::Prompt.new
    puts "Logging you in..."
    sleep(0.5)
    new_team = "Create New Team"
    saved_team = "See Saved Teams"
    wins_losses = "See Your Wins and Losses"
    vs_computer = "VS the Computer"
    vs_saved_teams = "VS Other Teams"
    exit_console = "EXIT"
    console_ar = [new_team, saved_team, wins_losses, vs_computer, vs_saved_teams, exit_console]
    while true
        sleep (1)
        puts `clear`
        console_response = @console_prompt.select("What would you like to do?", console_ar)
        if console_response == new_team
            my_username.new_team
        elsif console_response == saved_team
            my_username.my_teams
        elsif console_response == wins_losses
            my_username.calculate_wins_losses
        elsif console_response == vs_computer
            my_username.vs_computer
        elsif console_response == vs_saved_teams
            user_select_team = my_username.my_teams
            my_username.calculate_vs_other_team(user_select_team)
        elsif console_response == exit_console
            puts "Exiting..."
            sleep (0.5)
            puts `clear`
            exit
        end
    end
end