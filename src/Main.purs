module Main where

import Prelude
import Effect (Effect)
import Effect.Console (log)
import Data.Map as Map

import Data.Maybe (Maybe(..))
import Halogen as H
import Halogen.HTML as HH
import Halogen.HTML.Events as HE
import Halogen.HTML.Properties as HP
import Halogen.Aff as HA
import Halogen.VDom.Driver (runUI)

data Op =
  As { id :: String , val :: Int }

data Config =
  Config { env :: Map.Map String Int }

type State = Boolean

data Query a
  = Toggle a
  | IsOn (Boolean -> a)

type Input = Unit

data Message = Toggled Boolean

myButton :: forall m. H.Component HH.HTML Query Input Message m
myButton =
  H.component
    { initialState: const initialState
    , render
    , eval
    , receiver: const Nothing
    }
  where

  initialState :: State
  initialState = false

  render :: State -> H.ComponentHTML Query
  render state =
    let
      label = if state then "On" else "Off"
    in
      HH.button
        [ HP.title label
        , HE.onClick (HE.input_ Toggle)
        ]
        [ HH.text label ]

  eval :: Query ~> H.ComponentDSL State Query Message m
  eval = case _ of
    Toggle next -> do
      state <- H.get
      let nextState = not state
      H.put nextState
      H.raise $ Toggled nextState
      pure next
    IsOn reply -> do
      state <- H.get
      pure (reply state)

main :: Effect Unit
main = do
  log "Hello 🍝!"
  HA.runHalogenAff do
    body <- HA.awaitBody
    runUI myButton unit body
