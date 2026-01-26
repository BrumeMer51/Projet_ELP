module Download exposing (downloadFile, dowloadDef, fileDecoupe)

import Http
import Type exposing (Model(..), Msg(..), Definition, Fichier)
import Decodage as FctJson

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

fileDecoupe : String -> Fichier
fileDecoupe s = {liste = String.split " " s}