--- Imports nécessaires :
import Browser
import Html exposing (..)
import Html.Attributes exposing (style)
import Html.Events exposing (..)
import Http
import Json.Decode exposing (Decoder, map2, field, list, string)
import Random


--- Main :
main =
  Browser.element
    { init = init
    , update = update
    , subscriptions = subscriptions
    , view = view
    }


--- Model :
--- ici définit le type Model, le type Definition et la fonction init

type Model
  = Failure
  | LoadingFile
  | LoadingDef
  | SuccessFile Definition
  | SuccessDef Definition 

type alias Fichier =
  {
    liste : List String
  }

type alias Definition =
  { fichier : Fichier
  , mot : String
  , definitions : List (List String)
  }


init : () -> (Model, Cmd Msg)
init _ =
  (LoadingFile, getFile)


--- Update :
--- ici définir le type Msg et la fonction update
type Msg
  = GetFile
  | GotFile Fichier
  | PickIndex (Int)
  | RecupDef
  | GotDefFinal (Result Http.Error Definition)


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
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
--- ici définir la fonction view -> Model -> Html Msg et la fonction viewDef -> Model -> Html Msg
view : Model -> Html Msg


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








