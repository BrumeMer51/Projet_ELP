
--- Imports nécessaires :
import Browser
import Html exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode exposing (Decoder, map2, field, list, string)
import Random
import Html.Attributes exposing (..)
import Html.Events exposing (onInput, onClick)


--- Main :
main =
  Browser.element
    { init = init
    , update = update
    , subscriptions = subscriptions
    , view = view
    }


--- Model :
--- ici définir le type Model, le type Definition et la fonction init
type Model
  = Failure
  | LoadingFile
  | LoadingDef
  | Success Definition 

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




init : () -> (Model, Cmd Msg)
init _ =
  (Loading, getRandomWord)


--- Update :
--- ici définir le type Msg et la fonction update
type Msg
  = Guess String
  | SwitchAnswer Int
  | GetFile
  | GotFile Fichier
  | PickIndex (Int)
  | RecupDef
  | GotDefFinal (Result Http.Error Definition)

-- Gère les actions initiales et les messages des interactions utilisateur
update : Msg -> Definition -> Definition
update msg model =
  case msg of
    --- Met à jour le guess
    Guess guess ->
      { model | guess = guess }

    --- Détermine l'affichage ou non de la réponse
    SwitchAnswer switch ->
        case switch of 
            0 -> 
              { model | switch = 1}
            _ -> 
              { model | switch = 0}
      
    --- Téléchargement du fichier dès le début :
    GetFile ->
      (LoadingFile, downloadFile)
      
    --- Quand on a téléchargé le fichier, on lance le choix du mot :
    GotFile fichier ->
      let
        newModel = SuccessFile { fichier = fichier, mot = "", definitions = [] }
      in
        (newModel, randomIndexCmd fichier.liste) 
        
    --- Quand il faut tirer un mot aléatoire : (si le fichier est bien chargé)
    PickIndex i ->
      case model of 
        SuccessFile def -> let
            motChoisi = List.head(List.drop i def.fichier.liste)
            newDef = { def | mot = motChoisi }
          in 
            (SuccessFile newDef, Cmd.msg RecupDef)
          
    --- Une fois le mot choisi, on récupère le json de la définition sur le site :
    RecupDef -> 
      case model of 
        SuccessFile def -> (LoadingDef, dowloadDef def)
        _ -> (Failure, Cmd.none)
        
    --- Quand la définition est récupérée, on l'affiche :
    GotDefFinal result ->
      case result of
        Ok def ->
          (SuccessDef def, Cmd.none)

        Err _ ->
          (Failure, Cmd.none)


-- SUBSCRIPTIONS
subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none


--- View :
view : Definition -> Html Msg
view model =
  div []
    [ viewAnswer model
    , viewDefinition model
    , viewValidation model
    , viewInput "guess" "Guess" model.guess Guess
    , br [] []
    , button [ onClick (SwitchAnswer model.switch) ] [ text "Afficher la réponse ?" ]
    ]

-- Crée la zone d'écriture de la tentative
viewInput : String -> String -> String -> (String -> msg) -> Html msg
viewInput t p v toMsg =
  input [ type_ t, placeholder p, value v, onInput toMsg ] []

-- Affiche ou cache la réponse
viewAnswer : Definition -> Html msg
viewAnswer model =
  if model.switch == 1 then
    div [ style "color" "black" ][text "The word is ", text model.answer]
  else
    div [ style "color" "black" ][text "Here are the definitions : "]

-- Affiche la liste des définition en mettant la classe grammaticale en avant
viewDefinition model =
    div []
        (List.map
            (\group ->
                case group of
                    title :: items ->
                        div []
                            [ div [ style "font-weight" "bold" ] [ text title ]
                            , div [] (List.map (\i -> div [] [ text i ]) items)
                            ]

                    [] ->
                        text ""
            )
            model.definition
        )

-- Determine si la réponse est correcte 
viewValidation : Definition -> Html msg
viewValidation model =
  if model.guess == model.answer then
    div [ style "color" "green" ] [ text "You guessed right, the word is ", text model.answer]
  else
    div [ style "color" "red" ] [ text "Try to guess" ]

--- HTTP :
downloadFile : Cmd Msg
downloadFile = 
  Http.get{
    url = "https://perso.liris.cnrs.fr/tristan.roussillon/GuessIt/thousand_words_things_explainer.txt"
    , expect = Http.expectString GotFile fileDecoupe
  }

dowloadDef : def -> Cmd Msg
dowloadDef def = 
  Http.get{
    url = "https://api.dictionaryapi.dev/api/v2/entries/en/" ++ def.mot
    , expect = Http.expectJson GotDefFinal (defDecoder def.fichier def.mot)
  }





--- Fonctions annexes : 

randomIndexCmd : List String -> Cmd Msg
randomIndexCmd wordList =
    Random.generate PickIndex (Random.int 0 998)

fileDecoupe : String -> Fichier
fileDecoupe s = {liste = String.split " " s}


defDecoder : Fichier -> String -> Decoder Definition
defDecoder fichier mot =
    map Definition
        (\defs -> { fichier = fichier, mot = mot, definitions = defs })
        (field "meanings" (list meaningDecoder))
  

meaningDecoder = 
  map2
    (\partOfSpeech defs ->
            partOfSpeech :: defs
      )
      (field "partOfSpeech" string)
      (field "definitions" (list (field "definition" string)))
