module View exposing (view, viewInput, viewAnswer, viewDefinition, viewValidation)

import Type exposing (Model(..), Msg(..))

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput, onClick)

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
  FailureDef -> div[] [text "Erreur view FailureDef"]
  FailureFile -> div[] [text "Erreur view FailureFile"]

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
  FailureDef -> div[] [text "Erreur viewAnswer FailureDef"]
  FailureFile -> div[] [text "Erreur viewAnswer FailureFile"]

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
  FailureDef -> div[] [text "Erreur viewDefinition FailureDef"]
  FailureFile -> div[] [text "Erreur viewDefinition FailureFile"]

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
  FailureDef -> div[] [text "Erreur viewValidation FailureDef"]
  FailureFile -> div[] [text "Erreur viewValidation FailureFile"]