{-# LANGUAGE OverloadedStrings #-}

-- TODO
module HaskellWeekly.Template.NewsletterFeed
  ( newsletterFeedTemplate
  )
where

import qualified Data.List
import qualified Data.Maybe
import qualified Data.Ord
import qualified Data.Text
import qualified HaskellWeekly.Type.Date
import qualified HaskellWeekly.Type.Issue
import qualified HaskellWeekly.Type.Number
import qualified HaskellWeekly.Type.Route
import qualified Text.Atom.Feed
import qualified Text.Feed.Constructor
import qualified Text.Feed.Types

newsletterFeedTemplate
  :: String -> [HaskellWeekly.Type.Issue.Issue] -> Text.Feed.Types.Feed
newsletterFeedTemplate baseUrl issues =
  let
    atom = Text.Atom.Feed.nullFeed
      (feedId baseUrl)
      (Text.Atom.Feed.TextString "Haskell Weekly")
      (feedUpdated issues)
    entries = fmap (issueToEntry baseUrl) issues
  in Text.Feed.Constructor.feedFromAtom atom
    { Text.Atom.Feed.feedEntries = entries
    }

feedId :: String -> Text.Atom.Feed.URI
feedId baseUrl =
  Data.Text.pack . mappend baseUrl $ HaskellWeekly.Type.Route.routeToString
    HaskellWeekly.Type.Route.RouteNewsletterFeed

feedUpdated :: [HaskellWeekly.Type.Issue.Issue] -> Text.Atom.Feed.Date
feedUpdated =
  Data.Text.pack
    . maybe "2001-01-01T12:00:00Z" HaskellWeekly.Type.Date.dateToLongString
    . Data.Maybe.listToMaybe
    . Data.List.sortOn Data.Ord.Down
    . fmap HaskellWeekly.Type.Issue.issueDate

issueToEntry
  :: String -> HaskellWeekly.Type.Issue.Issue -> Text.Atom.Feed.Entry
issueToEntry baseUrl issue = Text.Atom.Feed.nullEntry
  (entryId baseUrl issue)
  (entryTitle issue)
  (entryUpdated issue)

entryId :: String -> HaskellWeekly.Type.Issue.Issue -> Text.Atom.Feed.URI
entryId baseUrl =
  Data.Text.pack
    . mappend baseUrl
    . HaskellWeekly.Type.Route.routeToString
    . HaskellWeekly.Type.Route.RouteIssue
    . HaskellWeekly.Type.Issue.issueNumber

entryTitle :: HaskellWeekly.Type.Issue.Issue -> Text.Atom.Feed.TextContent
entryTitle =
  Text.Atom.Feed.TextString
    . Data.Text.pack
    . mappend "Issue "
    . HaskellWeekly.Type.Number.numberToString
    . HaskellWeekly.Type.Issue.issueNumber

entryUpdated :: HaskellWeekly.Type.Issue.Issue -> Text.Atom.Feed.Date
entryUpdated =
  Data.Text.pack
    . HaskellWeekly.Type.Date.dateToLongString
    . HaskellWeekly.Type.Issue.issueDate