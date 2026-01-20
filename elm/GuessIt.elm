--- Imports nécessaires :
import Browser
import Html exposing (..)
import Http
import Json.Decode exposing (Decoder, map, map2, field, list, string)
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
  (LoadingFile, downloadFile)


--- Update :
--- ici définir le type Msg et la fonction update
type Msg
  = Guess String
  | SwitchAnswer Int
  | GetFile
  | GotFileResult (Result Http.Error String)
  | PickIndex (Int)
  | GotDefFinal (Result Http.Error Definition)

-- Gère les actions initiales et les messages des interactions utilisateur
update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    --- Met à jour le guess
    Guess guess -> case model of
        Success def -> let newDef = { def | guess = guess} in ( Success newDef, Cmd.none )
        _ -> (model, Cmd.none)

    --- Détermine l'affichage ou non de la réponse
    SwitchAnswer switch ->
        case switch of 
            0 -> case model of
              Success def -> let newDef = {def | switch = 1} in ( Success newDef, Cmd.none )
              _ -> (model, Cmd.none)
            _ -> case model of
              Success def -> let newDef = {def | switch = 0} in ( Success newDef, Cmd.none )
              _ -> (model, Cmd.none)
              
    --- Téléchargement du fichier dès le début :
    GetFile ->
      (LoadingFile, downloadFile)
      
    --- Quand on a téléchargé le fichier, on lance le choix du mot :
    GotFileResult result ->
      case result of
        Ok contenu ->
          let
            fichier = fileDecoupe contenu
            newModel =
              Success
                { fichier = fichier
                , mot = ""
                , definitions = []
                , guess = ""
                , switch = 0
                }
          in
          ( newModel, randomIndexCmd fichier.liste )

        Err _ ->
          ( Failure, Cmd.none )

        
    --- Quand il faut tirer un mot aléatoire : (si le fichier est bien chargé)
    PickIndex i ->
      case model of 
        Success def -> let newDef = 
                              { def
                              | mot = List.head(List.drop i def.fichier.liste)|> Maybe.withDefault "" 
                              } in (LoadingDef, dowloadDef def)
        _ -> (model, Cmd.none)
          

        
    --- Quand la définition est récupérée, on l'affiche :
    GotDefFinal result ->
      case result of
        Ok def ->
          (Success def, Cmd.none)

        Err _ ->
          (Failure, Cmd.none)


-- SUBSCRIPTIONS
subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none


--- View :
view : Model -> Html Msg
view model = case model of
  Success def ->
    div []
      [ viewAnswer model
      , viewDefinition model
      , viewValidation model
      , viewInput "guess" "Guess" def.guess Guess
      , br [] []
      , button [ onClick (SwitchAnswer def.switch) ] [ text "Afficher la réponse ?" ]
      ]
  LoadingDef -> div[] [text "Erreur view LoadingDef"]
  LoadingFile -> div[] [text "Erreur view LoadingFile"]
  Failure -> div[] [text "Erreur view Failure"]

-- Crée la zone d'écriture de la tentative
viewInput : String -> String -> String -> (String -> msg) -> Html msg
viewInput t p v toMsg =
  input [ type_ t, placeholder p, value v, onInput toMsg ] []

-- Affiche ou cache la réponse
viewAnswer : Model -> Html msg
viewAnswer model = case model of
  Success def ->
    if def.switch == 1 then
      div [ style "color" "black" ][text "The word is ", text def.mot]
    else
      div [ style "color" "black" ][text "Here are the definitions : "]
  LoadingDef -> div[] [text "Erreur viewAnswer LoadingDef"]
  LoadingFile -> div[] [text "Erreur viewAnswer LoadingFile"]
  Failure -> div[] [text "Erreur viewAnswer Failure"]

-- Affiche la liste des définition en mettant la classe grammaticale en avant
viewDefinition : Model -> Html msg
viewDefinition model = case model of
  Success def ->
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
            def.definitions
        )
  LoadingDef -> div[] [text "Erreur viewDefinition LoadingDef"]
  LoadingFile -> div[] [text "Erreur viewDefinition LoadingFile"]
  Failure -> div[] [text "Erreur viewDefinition Failure"]

-- Determine si la réponse est correcte 
viewValidation : Model -> Html msg
viewValidation model =case model of
  Success def ->
    if def.guess == def.mot then
      div [ style "color" "green" ] [ text "You guessed right, the word is ", text def.mot]
    else
      div [ style "color" "red" ] [ text "Try to guess" ]
  LoadingDef -> div[] [text "Erreur viewValidation LoadingDef"]
  LoadingFile -> div[] [text "Erreur viewValidation LoadingFile"]
  Failure -> div[] [text "Erreur viewValidation Failure"]

--- HTTP :
downloadFile : Cmd Msg
downloadFile = 
  Http.get{
    url = "https://perso.liris.cnrs.fr/tristan.roussillon/GuessIt/thousand_words_things_explainer.txt"
    , expect = Http.expectString GotFileResult
  }

dowloadDef : Definition -> Cmd Msg
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
    Json.Decode.map
        (\defs -> { fichier = fichier, mot = mot, definitions = defs, guess = "", switch = 0 })
        (field "meanings" (Json.Decode.list meaningDecoder))
  

meaningDecoder = 
  map2
    (\partOfSpeech defs ->
            partOfSpeech :: defs
      )
      (field "partOfSpeech" string)
      (field "definitions" (Json.Decode.list (field "definition" string)))
