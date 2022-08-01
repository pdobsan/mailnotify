{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ImportQualifiedPost #-}
{-# LANGUAGE PackageImports #-}

module MailNotify.Utilities
  ( monitor
  , decodeLoop
  )
where

import "base" System.IO qualified as SIO
import "bytestring" Data.ByteString (ByteString)
import "bytestring" Data.ByteString.Char8 qualified as BSC
import "libnotify" Libnotify
import "purebred-email" Data.MIME qualified as MIME
import "tailfile-hinotify" System.IO.TailFile (tailFile)
import "text" Data.Text qualified as TXT
import MailNotify.CommandLine

decodeLoop :: String -> IO ()
decodeLoop path = do
  h <- SIO.openFile path SIO.ReadMode
  c <- BSC.hGetContents h
  SIO.hClose h
  let ls = BSC.split '\n' c
      decode = TXT.unpack . MIME.decodeEncodedWords MIME.defaultCharsets
  mapM_ (putStrLn . decode) ls

popup :: Opts -> ByteString -> ByteString -> IO ByteString
popup config _ tailbs = do
  let hs = zipFromSubj $ BSC.split '\n' tailbs
  mapM_ decode hs
  return ""
  where
    decode (from, subj) =
      let from' = TXT.unpack $ MIME.decodeEncodedWords MIME.defaultCharsets from
          subj' = TXT.unpack $ MIME.decodeEncodedWords MIME.defaultCharsets subj
       in display_ (summary "You've got mail!"
                   <> body (from' <> "\n" <> subj')
                   <> Libnotify.timeout (MailNotify.CommandLine.timeout config)
                   <> Libnotify.icon (MailNotify.CommandLine.icon config))

-- tailFile :: FilePath           -- the file to tail
--   -> (a -> ByteString -> IO a) -- State update function.
--   -> IO a                      -- Monadic action for getting the initial state.
--   -> IO void                   -- The result action never returns!

monitor :: Opts -> IO ()
monitor config = do
  f <- SIO.openFile (maillog config) SIO.ReadMode
  tailFile (maillog config) (popup config) (BSC.hGetContents f)

zipFromSubj :: [ByteString] -> [(ByteString, ByteString)]
zipFromSubj mboxLines =
  let fs = filter isFrom mboxLines
      ss = filter isSubject mboxLines
   in zip fs ss
  where
    isFrom = BSC.isPrefixOf "From:"
    isSubject = BSC.isPrefixOf "Subject:"

