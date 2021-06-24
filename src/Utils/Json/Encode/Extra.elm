module Utils.Json.Encode.Extra exposing (..)

import Json.Encode as JE

maybeNull : (a -> JE.Value) -> Maybe a -> JE.Value
maybeNull encoder ma = case ma of
   (Just a) -> encoder a
   Nothing  -> JE.null
