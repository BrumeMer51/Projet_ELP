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


init : () -> (Model, Cmd Msg)
init _ =
  (Loading, getRandomWord)


--- Update :
--- ici définir le type Msg et la fonction update

-- SUBSCRIPTIONS
subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none


--- View :
--- ici définir la fonction view -> Model -> Html Msg et la fonction viewDef -> Model -> Html Msg
view : Model -> Html Msg

--- HTTP :
--- ici définir la fonction getRandomWord et la fonction defDecoder
