module Type exposing (Model(..), Fichier, Definition, Msg(..))

import Http

--- Model :
type Model
  = FailureFile
  | FailureDef
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

--- Messages :
type Msg
  = Guess String
  | SwitchAnswer Int
  | GetFile
  | GotFileResult (Result Http.Error String)
  | PickIndex (Int)
  | GotDefFinal (Result Http.Error Definition)
