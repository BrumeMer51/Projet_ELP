module Decodage exposing (defTotDecoder, racineDecoder, meaningsDecoder, soloMeaningDecoder, listDefinitionsDecoder, definitionDecoder)

import Json.Decode exposing (Decoder, map, map2, field, list, string)

--- Types nécessaires :
type alias Fichier =
  {
    liste : List String
  }

type alias Definition =
  { fichier : Fichier
  , mot : String
  , definitions : List (List String)
  , guess : String
  , switch : Int
  }


--- Fonctions de décodage : 
--- Pour décoder le json, on a une suite de fonctions qui vont chacune rentrer dans la couche suivante du json, pour extraire à la fin les définitions

--- Cette fonction indique qu'on va remplir le champ "definitions" avec la fonction racineDecoder
defTotDecoder : Fichier -> String -> Decoder Definition
defTotDecoder fichier mot =
    map
        (\defs ->
            { fichier = fichier
            , mot = mot
            , definitions = defs
            , guess = ""
            , switch = 0
            }
        )
        racineDecoder

--- Cette fonction permet de sélectionner le champ "meanings" et de le décoder
racineDecoder : Decoder (List (List String))
racineDecoder =
    list meaningsDecoder
        |> map List.concat

--- Cette fonction permet de rentrer dans le champ "Meanings" et de prendre chaque sens du mot
meaningsDecoder : Decoder (List (List String))
meaningsDecoder =
    field "meanings" (list soloMeaningDecoder)

--- Cette fonction permet de décoder chaque "partOfSpeech" présent dans le json
soloMeaningDecoder : Decoder (List String)
soloMeaningDecoder =
    map2
        (\part defs -> part :: defs)
        (field "partOfSpeech" string)
        listDefinitionsDecoder

--- Cette fonction permet de créer une liste contenant toutes les définitions du mots associés à une classe grammaticale 
listDefinitionsDecoder : Decoder (List String)
listDefinitionsDecoder =
    field "definitions" (list definitionDecoder)

--- Cette fonction se charge de décoder une seule définition
definitionDecoder : Decoder String
definitionDecoder =
    field "definition" string