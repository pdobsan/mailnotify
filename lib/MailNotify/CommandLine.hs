module MailNotify.CommandLine
  ( Opts(..)
  , getOpts
  , showVersion
  , version
  )
where

--import System.Environment
import Data.Version (showVersion)
import Libnotify
import Options.Applicative
import Paths_mailnotify (version)

data Opts = Opts
  { maillog :: !String
  , icon    :: !String
  , timeout :: !Timeout
  } deriving Show

instance Read Timeout where
  readsPrec _ s =
   let [(t, r)] = lex s
    in case t of
      "default" -> [(Default, r)]
      "infinite" -> [(Infinite, r)]
      x -> [(Custom (1000 * read x), r)]

getOpts :: IO Opts
getOpts = customExecParser (prefs showHelpOnEmpty) optsParser

optsParser :: ParserInfo Opts
optsParser = info
  (helper <*> versionOption <*> programOptions)
  (Options.Applicative.fullDesc <> progDesc "Mailnotify generates pop-up notifications about incoming email messages."
  <> header "mailnotify - Pop-up notification on received email.")

versionOption :: Parser (a -> a)
versionOption = do
  let verinfo = "mailnotify version " <> showVersion version
                <> "\nCopyright (C) Peter Dobsan 2022"
  infoOption verinfo (long "version" <> help "Show version")

programOptions :: Parser Opts
programOptions =
  Opts <$> argument str (metavar "<mail-log>"
                 <> help "Mail log file")
       <*> strOption (long "icon" <> short 'i' <> metavar "<icon>"
                 <> value "mail-unread-symbolic.symbolic"
                 <> showDefault
                 <> help "Icon name or file")
       <*> option auto (long "timeout" <> short 't' <> metavar "<timeout>"
                 <> value Infinite
                 <> showDefault
                 <> help "Possible timeouts: `default` use system's default; `infinite` no timeout; N in seconds."
                  )

