from bs4 import BeautifulSoup
import json
import requests

def get_questions_html():
    return requests.get('https://j-archive.com/listfjs.php').text

"""
{
    "episode_number": "9138",
    "round": "Final Jeopardy",
    "air_date": "2024-07-03",
    "category": "HISTORIC WOMEN",
    "answer": "In the 16th century, she changed the \"EW\" in her family name to a \"U\" to help her new French in-laws spell it more easily",
    "question": "Mary, Queen of Scots (Mary Stuart)"
}

"""
def parse_questions():
    s = BeautifulSoup(get_questions_html(), features='lxml')

    output = []
    for tr in s.select('#content tr'):
        game_details = tr.find_all('td')[0]
        ans_details = tr.find_all('td')[1]

        episode_number = game_details.text.split(', ')[0][1:].strip()
        air_date = game_details.text.split(', ')[1].split('aired ')[1].strip()

        category = ans_details.find_all('span')[0].text.strip()
        response = ans_details.select_one('.search_correct_response').text.strip()
        answer = ans_details.text.split(category+': ')[1].split(response)[0].strip()

        output.append({
            "round": "Final Jeopardy",
            "episode_number": episode_number,
            "air_date": air_date,
            "category": category,
            "answer": answer,
            "response": response
        })

    return output


if __name__ == '__main__':
    open('questions.json', 'w').write(json.dumps(parse_questions(), indent=4))