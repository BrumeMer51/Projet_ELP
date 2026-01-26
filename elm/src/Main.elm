module Main exposing (..)

--- Imports nécessaires :
import Browser
import Html exposing (..)
import Http
import Random
import Html.Attributes exposing (..)
import Html.Events exposing (onInput, onClick)

--- Imports des modules :
import Decodage as FctJson
import Type exposing (Model(..), Fichier, Definition, Msg(..))
import View exposing (view)


--- Main :
main =
  Browser.element
    { init = init
    , update = update
    , subscriptions = subscriptions
    , view = view
    }


init : () -> (Model, Cmd Msg)
init _ =
  (LoadingFile, downloadFile)


--- Update :

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
        Err _ -> (FailureFile, Cmd.none)
          

        
    --- Quand il faut tirer un mot aléatoire : (si le fichier est bien chargé)
    PickIndex i ->
      case model of 
        Success def -> let newDef = 
                              { def
                              | mot = List.head(List.drop i def.fichier.liste)|> Maybe.withDefault "" 
                              } in (LoadingDef, dowloadDef newDef)
        _ -> (model, Cmd.none)
          

        
    --- Quand la définition est récupérée, on l'affiche :
    GotDefFinal result ->
      case result of
        Ok def ->
          (Success def, Cmd.none)

        Err _ ->
          (FailureDef, Cmd.none)


-- SUBSCRIPTIONS
subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none




--- HTTP :
downloadFile : Cmd Msg
downloadFile = 
  Http.get{
    url = "../static/thousand_words_things_explainer.txt"
    , expect = Http.expectString GotFileResult
  }

dowloadDef : Definition -> Cmd Msg
dowloadDef def = 
  Http.get{
    url = "https://api.dictionaryapi.dev/api/v2/entries/en/" ++ def.mot
    , expect = Http.expectJson GotDefFinal (FctJson.defTotDecoder def.fichier def.mot)
  }





--- Fonctions annexes : 

randomIndexCmd : List String -> Cmd Msg
randomIndexCmd wordList =
    Random.generate PickIndex (Random.int 0 998)

fileDecoupe : String -> Fichier
fileDecoupe s = {liste = String.split " " s}


  
