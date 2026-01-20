--- Imports nécessaires :
import Browser
import Html exposing (..)
import Html.Attributes exposing (style)
import Html.Events exposing (..)
import Http
import Json.Decode exposing (Decoder, map4, field, int, string)
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
--- ici définir le type Model, le type Definition et la fonction init
type Model
  = Failure
  | Loading
  | Success Definition 

type alias Definition =
  { mot : String
  , --- à compléter
  }


--from here 
type alias Show =
  { guess : String
  , switch : Int
  , answer : String
  , definition : List (List String)
  }


init : Show
init =
  Show "" 0 "word" [["noun", "1", "2", "3"], ["verb", "1", "2"]]
--to here for the model of View


init : () -> (Model, Cmd Msg)
init _ =
  (Loading, getRandomWord)


--- Update :
--- ici définir le type Msg et la fonction update
type Msg
  = Guess String
  | SwitchAnswer Int

-- Gère les message des intéraction utilisateur
update : Msg -> Show -> Show
update msg model =
  case msg of
    Guess guess ->
      { model | guess = guess }

    SwitchAnswer switch ->
        case switch of 
            0 -> 
              { model | switch = 1}
            _ -> 
              { model | switch = 0}


-- SUBSCRIPTIONS
subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none


--- View :
--- ici définir la fonction view -> Model -> Html Msg et la fonction viewDef -> Model -> Html Msg
--- Principe : parcourir des listes et afficher avec la bonne police/taille de caractères..., et vérification du texte

view : Show -> Html Msg
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
viewAnswer : Show -> Html msg
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
viewValidation : Show -> Html msg
viewValidation model =
  if model.guess == model.answer then
    div [ style "color" "green" ] [ text "You guessed right, the word is ", text model.answer]
  else
    div [ style "color" "red" ] [ text "Try to guess" ]

--- HTTP :
--- ici définir la fonction getRandomWord et la fonction defDecoder
--- Principe : générer un nb aléatoire entre 0 et 999, récupérer la définition du mot concerné avec un requête HTTP, et décodé le json pour stocké tous les champs
