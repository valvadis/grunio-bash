
#
# Grunio-bash
# by Jakub Książek
# special thanks to arhn.eu
#
# v1.0
#
# TITLE SCREEN
tput civis
clear

cat << EOF
   _____                  _       ____            _     
  / ____|                (_)     |  _ \          | |    
 | |  __ _ __ _   _ _ __  _  ___ | |_) | __ _ ___| |__  
 | | |_ | '__| | | | '_ \| |/ _ \|  _ < / _\` / __| '_ \ 
 | |__| | |  | |_| | | | | | (_) | |_) | (_| \__ \ | | |
  \_____|_|   \__,_|_| |_|_|\___/|____/ \__,_|___/_| |_|
                                                        
                                                                                                   
	LEFT:     Z
   	RIGHT:    X


   	QUIT:     Q

                        Press any key to start the game.
EOF
read -s -n 1
clear

# SIGNALS
SIG_RIGHT=USR2
SIG_LEFT=IO
SIG_QUIT=WINCH

# CONFIGURATIONS
DELAY=0.4;
MAXRIGHT=48;
HEIGHT=15;
SPEED=0.3;

# DRAW FUNCTIONS
function draw_pig
{
    local pig_position=${1};
	local pig_direction=${2};
    
    local pig_line1="  ,,__ ";
    local pig_line2=":''__ )";
    local pig_line3="  *  * ";
	
	local rev_pig_line1=" __,,  ";
    local rev_pig_line2="( __'':";
    local rev_pig_line3=" *  *  ";
	
	if [ "${pig_direction}" == "L" ]; then
		tput cup $((HEIGHT-1)) $pig_position
		echo -n "${pig_line1}"
		tput cup $(($HEIGHT)) $pig_position
		echo -n "${pig_line2}"
		tput cup $((HEIGHT+1)) $pig_position
		echo -n "${pig_line3}"
	else
		tput cup $((HEIGHT-1)) $pig_position
		echo -n "${rev_pig_line1}"
		tput cup $(($HEIGHT)) $pig_position
		echo -n "${rev_pig_line2}"
		tput cup $((HEIGHT+1)) $pig_position
		echo -n "${rev_pig_line3}"
	fi
}

function draw_carrot
{
    local carrot_width=${1};
    local carrot_height=${2};

    tput cup ${carrot_width} ${carrot_height}
    echo -n "V";
}

# GAME LOOP
function game_loop 
{
	pig=30;
	carrot=(21 7);
	score=(0 -1);

    trap "direction='R';" $SIG_RIGHT
    trap "direction='L';" $SIG_LEFT
    trap "exit 1;" $SIG_QUIT
	
	while : 
	do
		# FETCH CONTROLS
		case "$direction" in
			L)
				[ $pig -gt 0 ] && ((pig=pig-2))
				;;
			R)
				[ $pig -lt $MAXRIGHT ] && ((pig=pig+2))
				;;
		esac

		# CARROT MOVE
		carrot[0]=$((carrot[0]+1));

		# IF PIG EATS CARROT
		if [ "${carrot[0]}" -gt "$((HEIGHT-1))" ] && [ "${carrot[1]}" -ge "$((pig))" ] && [ "${carrot[1]}" -le "$((pig+7))" ]; then
			carrot[0]=0;
			carrot[1]=$(((RANDOM % 48)+1));
			score[0]=$((score[0]+1));
			score[1]=$((score[1]+1));
		fi

		# IF CARROT HITS ON THE GROUND
		if [ "${carrot[0]}" -gt "$((HEIGHT+1))" ]; then
			carrot[0]=0;
			carrot[1]=$(((RANDOM % 48)+1));
			score[1]=$((score[1]+1));
		fi

		# DISPLAY GRAPHIC
		clear;
		draw_carrot "${carrot[@]}"
		draw_pig $pig $direction

		# DEBUG TOOLS
		tput cup $((HEIGHT+2)) 0
		echo -n "SCORE: ${score[0]}/${score[1]} PIG: $pig CARROT: ${carrot[0]} ${carrot[1]} ${time}"
		
		sleep $SPEED;
	done
}

# STARTS GAME LOOP AS NEW PROCESS
game_loop &

# CONTROL SYSTEM
game_pid=$!

while : 
do
	read -s -n 1 key
	case "$key" in
	z)
		kill -$SIG_LEFT $game_pid
		;;
	x)
		kill -$SIG_RIGHT $game_pid
		;;
	q)
		clear;
		kill -$SIG_QUIT $game_pid
		echo "Thank you for playing!"
		exit 0;
		;;
	esac
done