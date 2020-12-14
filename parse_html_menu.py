import sys
import urllib.request  
from bs4 import BeautifulSoup

# Fetch the html file
#response = urllib.request.urlopen('http://tutorialspoint.com/python/python_overview.htm')
#response = urllib.request.urlopen('http://metroidconstruction.com/hacks.php?sort=&dir=&filters%5B%5D=M1&filters%5B%5D=M2&filters%5B%5D=SM&filters%5B%5D=MF&filters%5B%5D=MZM&filters%5B%5D=MP1&filters%5B%5D=MP2&filters%5B%5D=MP3&filters%5B%5D=Unknown&filters%5B%5D=Boss+Rush&filters%5B%5D=Exploration&filters%5B%5D=Challenge&filters%5B%5D=Spoof&filters%5B%5D=Speedrun%2FRace&filters%5B%5D=Incomplete&filters%5B%5D=Quick+Play&filters%5B%5D=Improvement&filters%5B%5D=Vanilla%2B&search=&num_per_page=1000&source=retropiescript')

#urllib.request.urlretrieve("https://metroidconstruction.com/hacks.php?sort=&dir=&filters%5B%5D=M1&filters%5B%5D=M2&filters%5B%5D=SM&filters%5B%5D=MF&filters%5B%5D=MZM&filters%5B%5D=MP1&filters%5B%5D=MP2&filters%5B%5D=MP3&filters%5B%5D=Unknown&filters%5B%5D=Boss+Rush&filters%5B%5D=Exploration&filters%5B%5D=Challenge&filters%5B%5D=Spoof&filters%5B%5D=Speedrun%2FRace&filters%5B%5D=Incomplete&filters%5B%5D=Quick+Play&filters%5B%5D=Improvement&filters%5B%5D=Vanilla%2B&search=&num_per_page=50&source=retropiescript", filename="/home/pi/metroidconstructionapi/tmp/file.html")

if len(sys.argv) != 3:
    print("Incorrect aguments, needed 2\n- source html file to read\n- output folder for data\n\nexample:\npyhton3 parse_html_menu.py file.html output_folder\n")
    exit()


source_html=sys.argv[1]
output_folder=sys.argv[2]

monthsDict={"Jan": "01", "Feb":"02", "Mar":"03", "Apr":"04", "May":"05", "Jun":"06", "Jul":"07", "Aug":"08", "Sep":"09", "Oct":"10", "Nov":"11", "Dec":"12"}
response = urllib.request.urlopen('file://' + source_html)
html_doc = response.read()

# Parse the html file
soup = BeautifulSoup(html_doc, 'html.parser')

# Format the parsed html file
#strhtm = soup.html.body.find('tbody').prettify()
children = soup.html.body.find('tbody', recursive=True).find_all('tr', recursive=False)
#print(children)
#.find_all("tr" , recursive=False)

data_by_game={}
data_by_game_detailed={}
doc = ''
docsmall = ''
for child in children:
    td = child.td
    #print(' ')
    game_id = str(td.a.get('href'))[12:] # id
    game_title = str(td.a.find(text=True)) # Title
    td = td.find_next_sibling('td')
    game_author = td.a.find(text=True) # Author
    td = td.find_next_sibling('td')
    game_genre = td.find(text=True) # Genre
    td = td.find_next_sibling('td')
    game_type = td.img.get('alt') # Game (SM, M2, M1)
    td = td.find_next_sibling('td')
    game_date = td.find(text=True) # Date Made
    td = td.find_next_sibling('td')
    #print(td)
    game_completion = ''
    acyronym = td.acronym
    if acyronym != None:
        game_completion = td.acronym.find(text=True) # Completion Time
    else:
        game_completion = 'N/A'
    td = td.find_next_sibling('td')
    span = td.span
    avgRating = 'N/A'
    if span != None:
        avgRating = str(span.get('title'))
        if avgRating.startswith('Average rating: '):
            avgRating = avgRating[16:]
        if avgRating.endswith(' chozo orbs'):
            avgRating = avgRating[:-11]
        if avgRating.endswith(' chozo orb'):
            avgRating = avgRating[:-10]

    try:
        percentRating=str(float(avgRating) / float('5.0'))
        percentRating=percentRating[:5]
    except:
        percentRating='0'

    try:
        date_year=game_date[8:]
        date_month_text=game_date[:3]
        date_month=monthsDict[date_month_text]
        date_day=game_date[4:6]
        game_date_datetime=date_year + date_month + date_day + 'T000000'
    except:
        game_date_datetime='N/A'
    
    split = '|||'
    detailed_line = game_id + split + game_title + split + game_author + split + game_genre + split + game_type + split + game_date + split + game_completion + split + avgRating + split + percentRating + split + game_date_datetime + '\n'
    line = game_id + '\n' + game_title[:40] + split + game_author[:12] + split + game_completion + split + avgRating + '\n'
    
    if game_type in data_by_game:
        data_by_game[game_type] += line
        data_by_game_detailed[game_type] += detailed_line
    else:
        data_by_game[game_type] = line
        data_by_game_detailed[game_type] = detailed_line

    #if doc == '':
    #    doc += line
    #else:
    #    doc += '\n' + line
    
    #print(line)


for game_type in data_by_game:
    f = open(output_folder + '/' + game_type + '_menu_data.txt', "w")
    f.write(data_by_game[game_type])
    f.close()
    f = open(output_folder + '/' + game_type + '_menu_data_detailed.txt', "w")
    f.write(data_by_game_detailed[game_type])
    f.close()


#my_file = open(outputfile_short, "w")
#my_file.write(docsmall)
#my_file.close()
#my_file = open(outputfile_long, "w")
#my_file.write(doc)
#my_file.close()

# Print the first few characters
#print (strhtm[:225])
