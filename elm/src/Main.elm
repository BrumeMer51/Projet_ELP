module Main exposing (..)

--- Imports nécessaires :
import Browser

--- Imports des modules :
import Type exposing (Model(..), Msg(..))
import View exposing (view)
import Update exposing (update)
import Download exposing(downloadFile)


--- Main, création du browser :
main =
  Browser.element
    { init = init
    , update = update
    , subscriptions = subscriptions
    , view = view
    }

--- Initialisation :
init : () -> (Model, Cmd Msg)
init _ =
  (LoadingFile, downloadFile)


-- SUBSCRIPTIONS
subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none















  
