 
import json
import urllib.request
import urllib.error
import getpass

print("=== TEST INTELLIGENCE DE EDU-BOT ===")

api_key = getpass.getpass("Entre ta cle API : ")

url = "https://api.openai.com/v1/responses"

donnees = {
    "model": "gpt-5.5",
    "instructions": """
    Tu es EDU-BOT, un assistant scolaire intelligent.
    Tu aides les etudiants avec patience.
    Tu expliques les cours simplement et etape par etape.
    """,
    "input": "Bonjour EDU-BOT ! Presente-toi."
}

requete = urllib.request.Request(
    url,
    data=json.dumps(donnees).encode("utf-8"),
    headers={
        "Content-Type": "application/json",
        "Authorization": "Bearer " + api_key
    },
    method="POST"
)

try:
    with urllib.request.urlopen(requete, timeout=60) as reponse:
        resultat = json.loads(reponse.read().decode("utf-8"))

    print("\nEDU-BOT :")

    for element in resultat.get("output", []):
        if element.get("type") == "message":
            for contenu in element.get("content", []):
                if contenu.get("type") == "output_text":
                    print(contenu.get("text", ""))

except urllib.error.HTTPError as erreur:
    print("Erreur API :", erreur.code)
    print(erreur.read().decode("utf-8"))

except Exception as erreur:
    print("Erreur :", erreur)
