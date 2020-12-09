import sys
import urllib.request  
from bs4 import BeautifulSoup

# Fetch the html file
#response = urllib.request.urlopen('http://tutorialspoint.com/python/python_overview.htm')
#response = urllib.request.urlopen('http://metroidconstruction.com/hacks.php?sort=&dir=&filters%5B%5D=M1&filters%5B%5D=M2&filters%5B%5D=SM&filters%5B%5D=MF&filters%5B%5D=MZM&filters%5B%5D=MP1&filters%5B%5D=MP2&filters%5B%5D=MP3&filters%5B%5D=Unknown&filters%5B%5D=Boss+Rush&filters%5B%5D=Exploration&filters%5B%5D=Challenge&filters%5B%5D=Spoof&filters%5B%5D=Speedrun%2FRace&filters%5B%5D=Incomplete&filters%5B%5D=Quick+Play&filters%5B%5D=Improvement&filters%5B%5D=Vanilla%2B&search=&num_per_page=1000&source=retropiescript')

#urllib.request.urlretrieve("https://metroidconstruction.com/hacks.php?sort=&dir=&filters%5B%5D=M1&filters%5B%5D=M2&filters%5B%5D=SM&filters%5B%5D=MF&filters%5B%5D=MZM&filters%5B%5D=MP1&filters%5B%5D=MP2&filters%5B%5D=MP3&filters%5B%5D=Unknown&filters%5B%5D=Boss+Rush&filters%5B%5D=Exploration&filters%5B%5D=Challenge&filters%5B%5D=Spoof&filters%5B%5D=Speedrun%2FRace&filters%5B%5D=Incomplete&filters%5B%5D=Quick+Play&filters%5B%5D=Improvement&filters%5B%5D=Vanilla%2B&search=&num_per_page=50&source=retropiescript", filename="/home/pi/metroidconstructionapi/tmp/file.html")
source="metroidconstruction.com"

def print_help_and_exit():
    print ("\nTo use 'modify_gamelist.sh' pass a gamelist xml and then a command. The two commands are add/remove")
    print ("\n  Add:\nmodify_gamelist.sh gamelist.xml add id title filename rating releasedate developer genre imagefilename desc")
    print ("\n  Remove:\nmodify_gamelist.sh gamelist.xml remove id")
    exit()

if len(sys.argv) < 3:
    print ("Need at least two arguments.")
    print_help_and_exit()

gamelist_path=sys.argv[1]
command=sys.argv[2]

if command == "add" and len(sys.argv) != 12:
    print("wrong arguments for add")
    print_help_and_exit()
elif command == "remove" and len(sys.argv) != 4:
    print("wrong arguments for remove")
    print_help_and_exit()
elif command !="add" and command != "remove":
    print("Unknown command: " + command)
    print_help_and_exit()

response = urllib.request.urlopen('file://' + gamelist_path)
html_doc = response.read()

# Parse the html file
soup = BeautifulSoup(html_doc, 'lxml-xml')

# Format the parsed html file
#strhtm = soup.html.body.find('tbody').prettify()
games = soup.gameList.find_all("game", recursive=False)

# Parse game arguments
game_id=sys.argv[3]
if command == "add":
    game_title=sys.argv[4]
    game_filename=sys.argv[5]
    game_rating=sys.argv[6]
    game_release_date=sys.argv[7]
    game_developer=sys.argv[8]
    game_genre=sys.argv[9]
    game_image_filename=sys.argv[10]
    game_desc=sys.argv[11]
    game_path="./" + game_filename
    game_image_path="./media/images/" + game_filename


# game_id="1234"
# game_title="Super Metroid"
# game_filename="Super Metroid.smc"
# game_rating="4.7"
# game_release_date="10-12-2020"
# game_developer="Author"
# game_genre="Author"
# game_image_filename="Super Metroid Zero Mission.png"
# game_desc="Long description goes here"


#print(games[0])

# <b><a href="http://www.example.com"></a></b>

def append_tag(parent_node, node_name, node_value):
    tag = soup.new_tag(node_name)
    tag.append(node_value)
    parent_node.append(tag)
    
def save_file():
    xml = str(soup) #.prettify()
    file = open(gamelist_path, "w")
    file.write(xml)
    file.close()
    print("File Saved!")

def remove_game_node():
    for game in games:
        if source is None or game.get("source") == source:
            #print("Found the source")
            if game_id == game.get('id'):
                print("Removing node:")
                print(game)
                game.decompose()    
                save_file()
                exit()
    print("No game found with source: " + source + " and id: " + game_id)

def add_game_node():
    remove_game_node()
    
    game_node = soup.new_tag("game", id=game_id, source="metroidconstruction.com")
    append_tag(game_node, "name", game_title)
    append_tag(game_node, "path", "./" + game_filename)
    append_tag(game_node, "desc", game_desc)
    append_tag(game_node, "rating", game_rating)
    append_tag(game_node, "releasedate", game_release_date)
    append_tag(game_node, "developer", game_developer)
    append_tag(game_node, "genre", game_genre)
    append_tag(game_node, "image", "./media/images/" + game_image_filename)
    soup.gameList.append(game_node)
    print("Adding node:")
    print(game_node)
    save_file()

if command == "add":
    add_game_node()
elif command == "remove":
    remove_game_node()
else:
    print("Unknown command " + command + ". Use 'add' or 'remove'")