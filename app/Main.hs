module Main where

import MailNotify.CommandLine
import MailNotify.Utilities
import System.IO

main :: IO ()
main = do
  opts <- getOpts
  print opts
  hFlush stdout
  monitor opts

